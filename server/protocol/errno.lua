local errno = {
ACCOUNT_CREATE = 1,	--创建用户失败
ACCOUNT_NO_CHALLENGE = 2,	--挑战信息失败
ACCOUNT_NO_USER = 3,		--用户不存在
ACCOUNT_NO_PASSWORD = 4,	--密码不对
ACCOUNT_NO_GATEID = 5,		--网关不存在
ACCOUNT_TOKEN_TIMEOUT = 6,	--获取登录session超时
ACCOUNT_KICK_TIMEOUT = 7,	--踢除已有玩家超时
ACCOUNT_TOKEN_INVALID = 8,	--token失效

ROLE_NONEXIST = 100,		--角色不存在

}

return errno

