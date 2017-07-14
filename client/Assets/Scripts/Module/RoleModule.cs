using System.Collections.Generic;
using UnityEngine;
namespace Module {
public struct BasicSt {
	/*
	BasicSt() {
		uid = 0;
		name = "hello";
		exp = 0;
		level = 0;
		gold = 0;
		hp = 0;
	}*/
	public string name;
	public int exp;
	public int level;
	public int gold;
	public int hp;
}

public struct PropSt {
	public int atk;
	public int def;
	public int matk;
	public int mdef;
}

public class Role {
	public static bool firstlogin = true;
	public static int uid;
	public static int token;
	public static BasicSt Basic;
	public static PropSt Prop;
	public static Dictionary<int, DB.IdCount> bag = new Dictionary<int, DB.IdCount>();
	public static Vector3 pos = Vector3.zero;
}
}

