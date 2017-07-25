#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <math.h>
#include "aoi.h"

static int
lequal(lua_State *L)
{
	float a = luaL_checknumber(L, 1);
	float b = luaL_checknumber(L, 2);
	int e = fabs(a - b) < 0.01f;
	lua_pushboolean(L, e);
	return 1;
}

static int
lnequal(lua_State *L)
{
	float a = luaL_checknumber(L, 1);
	float b = luaL_checknumber(L, 2);
	int e = fabs(a - b) > 0.01f;
	lua_pushboolean(L, e);
	return 1;
}

static int
ldistance(lua_State *L)
{
	float distance;
	float x1 = luaL_checknumber(L, 1);
	float y1 = luaL_checknumber(L, 2);
	float x2 = luaL_checknumber(L, 3);
	float y2 = luaL_checknumber(L, 4);
	distance = sqrtf((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
	lua_pushnumber(L, distance);
	return 1;
}

static int
lfollow(lua_State *L)
{
	float dist , dx, dy, move;
	float x1 = luaL_checknumber(L, 1);
	float y1 = luaL_checknumber(L, 2);
	float x2 = luaL_checknumber(L, 3);
	float y2 = luaL_checknumber(L, 4);
	float speed = luaL_checknumber(L, 5);
	int time = luaL_checkinteger(L, 6);
	dx = x2 - x1;
	dy = y2 - y1;
	dist = sqrtf(dx * dx + dy * dy);
	move = (speed * (float)time / 1000) / dist;
	if (move > 1.0f)
		move = 1.0f;
	lua_pushnumber(L, x1 + dx * move);
	lua_pushnumber(L, y1 + dy * move);
	return 2;
}

int
luaopen_aux_c(lua_State *L)
{
	luaL_Reg tbl[] = {
		{"eq", lequal},
		{"neq", lnequal},
		{"dist", ldistance},
		{"follow", lfollow},
		{NULL, NULL},
	};
	luaL_checkversion(L);
	luaL_newlib(L, tbl);
	return 1;
}
