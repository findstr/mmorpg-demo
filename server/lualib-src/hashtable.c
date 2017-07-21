#include <stdio.h>
#include <stdlib.h>
#include "hashtable.h"

struct hash_slot {
	int id;
	int next;
	void *obj;
};

struct hash_table {
	int cap;
	struct hash_slot *slot;
	struct hash_slot *lastfree;
};

#define	HASH(id)	((id))
#define my_malloc(size)	malloc(size)
#define my_realloc(ptr, size) realloc(ptr, size)
#define my_free(ptr)	free(ptr)

static inline void
hash_createslot(struct hash_table *hash, int size)
{
	int i;
	struct hash_slot *slot;
	hash->cap = size;
	slot = my_malloc(sizeof(struct hash_slot) * size);
	hash->slot = slot;
	for (i = 0; i < size; i++) {
		slot->id = -1;
		slot->next = -1;
		++slot;
	}
	hash->lastfree = slot;
}

static inline struct hash_slot *
mainposition(struct hash_table *tbl, int id)
{
	int hash = HASH(id) % tbl->cap;
	return &tbl->slot[hash];
}

static inline struct hash_slot *
getfreeslot(struct hash_table *tbl)
{
	while (tbl->lastfree > tbl->slot) {
		tbl->lastfree--;
		if (tbl->lastfree->id == -1)
			return tbl->lastfree;
	}
	return NULL;
}

static int
slotuse(struct hash_table *hash)
{
	int i;
	int count = 1;
	struct hash_slot *slot = hash->slot;
	for (i = 0; i < hash->cap; i++) {
		if (slot[i].obj != NULL)
			count++;
	}
	return count;
}

static void
rehash(struct hash_table *hash)
{
	int i;
	int ocap = hash->cap;
	int suse = slotuse(hash);
	struct hash_slot *oslot = hash->slot;
	hash_createslot(hash, suse * 2);
	for (i = 0; i < ocap; i++) {
		struct hash_slot *slot = &oslot[i];
		if (slot->id == -1)
			continue;
		hash_set(hash, slot->id, slot->obj);
	}
	my_free(oslot);
	return ;
}

static struct hash_slot *
hash_getslot(struct hash_table *hash, int id)
{
	struct hash_slot *slot = mainposition(hash, id);
	for (;;) {
		if (slot->id == id)
			return slot;
		int next = slot->next;
		if (next == -1)
			return NULL;
		slot = &hash->slot[next];
	}
	return NULL;
}

void *
hash_get(struct hash_table *hash, int id)
{
	struct hash_slot *slot = hash_getslot(hash, id);
	if (slot)
		return slot->obj;
	return NULL;
}

void
hash_set(struct hash_table *hash, int id, void *obj)
{
	struct hash_slot *mp = hash_getslot(hash, id);
	if (mp) {
		mp->obj = obj;
		return ;
	}
	mp = mainposition(hash, id);
	if (mp->id == -1) {
		// good! it's empty
		mp->id = id;
		mp->obj = obj;
		mp->next = -1;
	} else {
		struct hash_slot *free = getfreeslot(hash);
		if (free == NULL) {
			rehash(hash);
			return hash_set(hash, id, obj);
		}
		int key = mp->id;
		struct hash_slot *omp = mainposition(hash, key);
		if (omp == mp) {	//same mainposition
			free->id = id;
			free->obj = obj;
			free->next = mp->next;
			mp->next = free - hash->slot;
		} else {		//collide
			struct hash_slot *s = omp;
			struct hash_slot *n;
			struct hash_slot *slot = hash->slot;
			while ((n = &slot[s->next]) != mp)
				s = n;
			s->next = free - hash->slot;//correct 'next'
			*free = *mp;
			mp->id = id;
			mp->obj = obj;
			mp->next = -1;
		}
	}
	return ;
}

void
hash_foreach(struct hash_table *hash, hash_iter_t iter, void *ud)
{
	int i;
	int size = hash->cap;
	struct hash_slot *slot = hash->slot;
	for (i = 0; i < size; i++) {
		if (slot[i].id == -1)
			continue;
		iter(slot[i].id, slot[i].obj, ud);
	}
	return ;
}

struct hash_table *
hash_create(int presize)
{
	struct hash_table *hash = my_malloc(sizeof(*hash));
	hash_createslot(hash, presize);
	return hash;
}

void
hash_free(struct hash_table *hash)
{
	my_free(hash->slot);
	my_free(hash);
	return ;
}




