#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "hashtable.h"
#include "aoi.h"

#define	GRID (3.0f)
#define	RADIUS 9.0f

#define	MARK_CLEAR	(0)
#define	MARK_ENTER	(1)
#define	MARK_LEAVE	(2)

struct object {
	int id;
	float radius;
	float coord[2];
	int tower[2];
	struct object *prev;
	struct object *next;
};

struct tower {
	struct object *movers;
	int markud;
};

struct event_queue {
	int idx;
	int cap;
	int cnt;
	struct aoi_event *arr;
};

struct mark_buffer {
	int idx;
	int cap;
	int *arr;
};

struct aoi {
	int region[2];
	struct tower *scene;
	struct hash_table *hash;
	struct mark_buffer mark;
	struct event_queue *event;
};

#define my_malloc(size)	malloc(size)
#define my_realloc(ptr, size) realloc(ptr, size)
#define my_free(ptr) free(ptr)
#define	toweridx(aoi, x, z) ((x) * aoi->region[1] + (z))

static void
tower_create(struct aoi *aoi, float region[2])
{
	int i;
	region[0] /= GRID;
	region[1] /= GRID;
	aoi->region[0] = region[0];
	aoi->region[1] = region[1];
	int size = (region[0] + 1) * (region[1] + 1) + 1;
	struct tower *scene = my_malloc(sizeof(*scene) * size);
	for (i = 0; i < size; i++) {
		scene[i].movers = NULL;
		scene[i].markud = 0;
	}
	aoi->scene = scene;
	return ;
}

static void
tower_free(struct aoi *aoi)
{
	my_free(aoi->scene);
	return ;
}

static void
tower_link(struct tower *tower, struct object *obj)
{
	obj->prev = NULL;
	obj->next = tower->movers;
	if (tower->movers)
		tower->movers->prev = obj;
	tower->movers = obj;
	return ;
}

static void
tower_unlink(struct tower *tower, struct object *obj)
{
	if (obj->next)
		obj->next->prev = obj->prev;
	if (obj->prev)
		obj->prev->next = obj->next;
	else	//head
		tower->movers = obj->next;
	return ;
}

static struct event_queue *
event_create(int size)
{
	struct event_queue *q;
	q = my_malloc(sizeof(*q));
	q->idx = 0;
	q->cnt = 0;
	q->cap = size;
	q->arr = my_malloc(sizeof(struct aoi_event) * size);
	return q;
}

static void
event_free(struct event_queue *q)
{
	my_free(q->arr);
	my_free(q);
}

static inline void
event_push(struct event_queue *q, int mover, int watcher, int mode)
{
	if (q->cnt >= q->cap) {
		int sz = q->cap * 2;
		q->cap = sz;
		sz *= sizeof(struct aoi_event);
		q->arr = my_realloc(q->arr, sz);
	}
	struct aoi_event *e = &q->arr[q->cnt++];
	e->mover = mover;
	e->watcher = watcher;
	e->mode = mode;
	return ;
}

static inline void
mark_resize(struct mark_buffer *mark)
{
	mark->cap *= 2;
	mark->arr = my_realloc(mark->arr, mark->cap * sizeof(int));
}

static inline void
mark_create(struct mark_buffer *mark)
{
	mark->idx = 0;
	mark->cap = 16;
	mark->arr = NULL;
	mark_resize(mark);
}

static inline void
mark_free(struct mark_buffer *mark)
{
	my_free(mark->arr);
}

static inline void
mark_clear(struct mark_buffer *mark)
{
	mark->idx = 0;
}

typedef void (* travel_t)(struct aoi *aoi, struct tower *tower, int ud);

static void
around_travel(struct aoi *aoi, float coord[2], float radius, travel_t cb, int ud)
{
	int x, z;
	float start[2];
	float stop[2];
	int startn[2];
	int stopn[2];
	float zwidth = aoi->region[1];
	struct tower *scene = aoi->scene;
	start[0] = coord[0] - radius;
	start[1] = coord[1] - radius;
	stop[0] = coord[0] + radius;
	stop[1] = coord[1] + radius;
	if (start[0] < 0.0f)
		start[0] = 0.0f;
	if (start[1] < 0.0f)
		start[1] = 0.0f;
	startn[0] = floor(start[0] / GRID);
	startn[1] = floor(start[1] / GRID);
	stopn[0] = ceil(stop[0] / GRID);
	stopn[1] = ceil(stop[1] / GRID);
	if (stopn[0] > aoi->region[0])
		stopn[0] = aoi->region[0];
	if (stopn[1] > aoi->region[1])
		stopn[1] = aoi->region[1];
	for (x = startn[0]; x <= stopn[0]; x++) {
		int xid = x * zwidth;
		for (z = startn[1]; z <= stopn[1]; z++) {
			int id = xid + z;
			cb(aoi, &scene[id], ud);
		}
	}
	return ;
}

static inline int
object_sid(struct aoi *aoi, struct object *obj)
{
	int x = obj->tower[0];
	int z = obj->tower[1];
	return toweridx(aoi, x, z);
}

static inline void
object_towerxz(struct object *obj)
{
	obj->tower[0] = obj->coord[0] / GRID;
	obj->tower[1] = obj->coord[1] / GRID;
}

static inline struct object *
object_new(struct aoi *aoi, int id, float coord[2], float radius)
{
	int sid;
	struct tower *tower;
	struct object *obj = my_malloc(sizeof(*obj));
	obj->id = id;
	obj->radius = radius;
	obj->coord[0] = coord[0];
	obj->coord[1] = coord[1];
	object_towerxz(obj);
	obj->next = NULL;
	obj->prev = NULL;
	sid = toweridx(aoi, obj->tower[0], obj->tower[1]);
	tower = &aoi->scene[sid];
	tower_link(tower, obj);
	return obj;
}


static inline void
tower_mark(struct aoi *aoi, struct tower *tower, int ud)
{
	if (tower->markud) {
		tower->markud = 0;
	} else {
		struct mark_buffer *mark = &aoi->mark;
		tower->markud = ud;
		if (mark->idx >= mark->cap)
			mark_resize(mark);
		mark->arr[mark->idx++] = tower - aoi->scene;
	}
}

static inline void
tower_notify(struct tower *t, struct event_queue *q,  int id, int mode)
{
	struct object *obj = t->movers;
	while (obj != NULL) {
		int watch = obj->id;
		if (watch != id)
			event_push(q, id, watch, mode);
		obj = obj->next;
	}
}

static inline void
tower_enter(struct aoi *aoi, struct tower *tower, int id)
{
	tower_notify(tower, aoi->event, id, 'E');
}

static inline void
update_move(struct aoi *aoi, struct object *obj, float coord[2])
{
	int i;
	int id = obj->id;
	struct tower *tower;
	struct mark_buffer *mark = &aoi->mark;
	struct tower *scene = aoi->scene;
	struct event_queue *q = aoi->event;
	around_travel(aoi, obj->coord, obj->radius, tower_mark, MARK_LEAVE);
	around_travel(aoi, coord, obj->radius, tower_mark, MARK_ENTER);
	for (i = 0; i < aoi->mark.idx; i++) {
		int sid = aoi->mark.arr[i];
		tower = &scene[sid];
		if (tower->markud == MARK_ENTER) { //watch visible zone
			tower_notify(tower, q, id, 'E');
			tower->markud = 0;
		} else if (tower->markud == MARK_LEAVE) { //invasible zone
			tower_notify(tower, q, id, 'L');
			tower->markud = 0;
		}
	}
	mark_clear(mark);
	tower = &scene[object_sid(aoi, obj)];
	tower_unlink(tower, obj);
	obj->coord[0] = coord[0];
	obj->coord[1] = coord[1];
	object_towerxz(obj);
	tower = &scene[object_sid(aoi, obj)];
	tower_link(tower, obj);
	return ;
}

void
aoi_move(struct aoi *aoi, int id, float coord[2])
{
	float radius = RADIUS;
	struct object *obj;
	obj = hash_get(aoi->hash, id);
	assert(coord[0] / GRID <= aoi->region[0]);
	assert(coord[1] / GRID <= aoi->region[1]);
	if (obj == NULL) {
		obj = object_new(aoi, id, coord, radius);
		hash_set(aoi->hash, id, obj);
		around_travel(aoi, coord, radius, tower_enter, id);
	} else {
		int x = coord[0] / GRID;
		int z = coord[1] / GRID;
		if (x == obj->tower[0] && z == obj->tower[1])
			return ;
		update_move(aoi, obj, coord);
	}
}

void
aoi_leave(struct aoi *aoi, int id)
{
	struct object *obj;
	struct tower *tower;
	obj = hash_get(aoi->hash, id);
	if (obj == NULL)
		return ;
	hash_set(aoi->hash, id, NULL);
	tower = &aoi->scene[object_sid(aoi, obj)];
	tower_unlink(tower, obj);
	return ;
}

int
aoi_detect(struct aoi *aoi, struct aoi_event **event)
{
	struct event_queue *q = aoi->event;
	if (q->cnt == q->idx) {
		q->cnt = 0;
		q->idx = 0;
		return 0;
	} else {
		assert(q->cnt > q->idx);
		*event = &q->arr[q->idx++];
		return 1;
	}
}

static void
dump_tower(struct tower *t, float x, float z)
{
	struct object *obj;
	printf("-----tower:%f-%f\n", x, z);
	obj = t->movers;
	while (obj) {
		printf("obj:%d %f-%f\n", obj->id, obj->coord[0], obj->coord[1]);
		obj = obj->next;
	}
}

void
aoi_dump(struct aoi *aoi)
{
	int x, z;
	struct tower *t;
	printf("---------dump-----------\n");
	for (x = 0; x < aoi->region[0]; x++) {
		int xi = x * aoi->region[1];
		for (z = 0; z < aoi->region[1]; z++) {
			int sid = xi + z;
			t = &aoi->scene[sid];
			if (t->movers == NULL)
				continue;
			dump_tower(t, x, z);
		}
	}
}

struct aoi *
aoi_create(float region[2], aoi_alloc_t alloc, void *ud)
{
	struct aoi *aoi;
	aoi = (struct aoi *)alloc(ud, sizeof(*aoi));
	mark_create(&aoi->mark);
	tower_create(aoi, region);
	aoi->hash = hash_create(64);
	aoi->event = event_create(64);
	return aoi;
}

static void
obj_free(int id, void *obj, void *ud)
{
	(void)id;
	(void)ud;
	if (obj != NULL)
		my_free(obj);
	return ;
}

void
aoi_free(struct aoi *aoi)
{
	hash_foreach(aoi->hash, obj_free, NULL);
	hash_free(aoi->hash);
	event_free(aoi->event);
	mark_free(&aoi->mark);
	tower_free(aoi);
	return;
}


