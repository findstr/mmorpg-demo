#include <math.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "hashtable.h"
#include "aoi.h"

struct user {
	int id;
	float coord[2];
	struct hash_table *around;
};

static struct user users[10];

static void
update_user(struct aoi *scene, struct user *u)
{
	struct aoi_event *e;
	printf("--------%d from x:%f z:%f", u->id, u->coord[0], u->coord[1]);
	u->coord[0] = random() % 20;
	u->coord[1] = random() % 20;
	printf(" to x:%f z:%f\n", u->coord[0], u->coord[1]);
	aoi_move(scene, u->id, u->coord);
	while (aoi_detect(scene, &e)) {
		void *n;
		assert(e->mover == u->id);
		if (e->mode == 'E') {
			n = u;
		} else if (e->mode == 'L') {
			n = NULL;
		}
		struct user *w = &users[e->watcher];
		printf("mover:%d watcher:%d mode:%c %p\n", u->id,
				e->watcher, e->mode, n);
		printf("mover x:%f z:%f\n", u->coord[0], u->coord[1]);
		printf("watch x:%f z:%f\n", w->coord[0], w->coord[1]);
		hash_set(u->around, e->watcher, n);
		hash_set(w->around, u->id, n);
		assert(hash_get(w->around, u->id) == n);
	}
}

static inline float
distance(struct user *a, struct user *b)
{
	float x = a->coord[0] - b->coord[0];
	float z = a->coord[1] - b->coord[1];
	return sqrt(x * x + z * z);
}

static void
iter(int id, void *obj, void *ud)
{
	if (obj == NULL)
		return ;
	struct user *u = &users[id];
	struct user *o = (struct user *)ud;
	printf("around %d x:%f z:%f distance:%f\n", id,
			u->coord[0], u->coord[1],
			distance(u, o));
}

static void
dump_user(struct user *u)
{
	printf("========= id: %d x:%f z:%f %p ==========\n",
		u->id, u->coord[0], u->coord[1], u->around);
	hash_foreach(u->around, iter, u);
}

int main()
{
	int i, j;
	float region[2] = {100, 100};
	struct aoi *scene = aoi_create(region);
	for (i = 0; i < 10; i++) {
		struct user *u = &users[i];
		u->coord[0] = 0.0f;
		u->coord[1] = 0.0f;
		u->id = i;
		u->around = hash_create(64);
	}
	for (i = 0; i < 5; i++) {
		for (j = 0; j < 10; j++)
			update_user(scene, &users[j]);
	}
	for (i = 0; i < 10; i++) {
		dump_user(&users[i]);
	}
	aoi_dump(scene);
	aoi_free(scene);
	return 0;
}

