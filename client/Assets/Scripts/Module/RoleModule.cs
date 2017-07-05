using System.Collections.Generic;
using UnityEngine;
namespace Module {
public class Role {
	public static int uid = 0;
	public static string name = "hello";
	public static int level = 0;
	public static int exp = 0;
	public static int hp = 0;
	public static Vector3 pos = Vector3.zero;
	public static Dictionary<int, DB.IdCount> prop = new Dictionary<int, DB.IdCount>();
	public static Dictionary<int, DB.IdCount> bag = new Dictionary<int, DB.IdCount>();
}
}

