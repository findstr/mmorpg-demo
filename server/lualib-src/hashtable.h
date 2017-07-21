#ifndef	_HASH_TABLE_H
#define	_HASH_TABLE_H

struct hash_table;

typedef void (* hash_iter_t)(int id, void *obj, void *ud);

struct hash_table *hash_create(int presize);
void hash_free(struct hash_table *hash);
void hash_set(struct hash_table *hash, int id, void *obj);
void *hash_get(struct hash_table *hash, int id);
void hash_foreach(struct hash_table *hash, hash_iter_t iter, void *ud);



#endif

