#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include "aoi.h"

static int
lgc(lua_State *L)
{
	struct aoi *aoi;
	aoi = luaL_checkudata(L, 1, "aoi");
	aoi_free(aoi);
	return 0;
}


static int
lstart(lua_State *L)
{
	float region[2];
	region[0] = luaL_checknumber(L, 1);
	region[1] = luaL_checknumber(L, 2);
	aoi_create(region, (aoi_alloc_t)lua_newuserdata, L);
	if (luaL_newmetatable(L, "aoi")) {
		lua_pushliteral(L, "__gc");
		lua_pushcfunction(L, lgc);
		lua_settable(L, -3);
	}
	lua_setmetatable(L, -2);
	return 1;
}

#define	AOI	(1)
#define	ID	(2)
#define X	(3)
#define Z	(4)
#define	ENTER	(5)
#define	LEAVE	(6)

static int
lupdate(lua_State *L)
{
	int id;
	struct aoi *aoi;
	float coord[2];
	struct aoi_event *e;
	int enteri = 0;
	int leavei = 0;
	aoi = luaL_checkudata(L, AOI, "aoi");
	id = luaL_checkinteger(L, ID);
	coord[0] = luaL_checknumber(L, X);
	coord[1] = luaL_checknumber(L, Z);
	aoi_move(aoi, id, coord);
	while (aoi_detect(aoi, &e)) {
		assert(e->mover == id);
		lua_pushinteger(L, e->watcher);
		if (e->mode == 'E') {
			lua_rawseti(L, ENTER, ++enteri);
		} else {
			assert(e->mode == 'L');
			lua_rawseti(L, LEAVE, ++leavei);
		}
	}
	lua_pushinteger(L, enteri);
	lua_pushinteger(L, leavei);
	return 2;
}

static int
lleave(lua_State *L)
{
	int id;
	struct aoi *aoi;
	aoi = luaL_checkudata(L, AOI, "aoi");
	id = luaL_checkinteger(L, ID);
	aoi_leave(aoi, id);
	return 0;
}

int
luaopen_aoi_c(lua_State *L)
{
	luaL_Reg tbl[] = {
		{"start", lstart},
		{"update", lupdate},
		{"leave", lleave},
		{NULL, NULL},
	};
	luaL_checkversion(L);
	luaL_newlib(L, tbl);
	return 1;
}
