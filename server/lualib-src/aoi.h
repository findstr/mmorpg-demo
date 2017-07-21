#ifndef	_AOI_H
#define	_AOI_H

struct aoi;
struct aoi_event {
	int mover;
	int watcher;
	//mode = 'E(enter)', 'L(leave)'
	int mode;
};

typedef void *(* aoi_alloc_t)(void *ud, size_t sz);

struct aoi *aoi_create(float region[2], aoi_alloc_t alloc, void *ud);
void aoi_free(struct aoi *aoi);
void aoi_leave(struct aoi *aoi, int id);
void aoi_move(struct aoi *aoi, int id, float coord[2]);
int aoi_detect(struct aoi *aoi, struct aoi_event **event);
void aoi_dump(struct aoi *aoi);

#endif

