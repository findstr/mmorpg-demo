using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterManager {
	private static Dictionary<int, Character> pool = new Dictionary<int, Character>();
	public static Character Create(int uid, string name, int hp, Vector3 pos) {
		if (pool.ContainsKey(uid))
			return pool[uid];
		var obj = Tool.InstancePrefab("Character/Character01", pos, Quaternion.identity);
		Debug.Assert(obj);
		Character c = obj.GetComponent<Character>();
		pool[uid] = c;
		c.Name = name;
		c.HP = hp;
		return c;
	}
	public static Character Get(int uid) {
		if (pool.ContainsKey(uid))
			return pool[uid];
		return null;
	}
	public static void Remove(int uid) {
		var c = Get(uid);
		if (c == null)
			return ;
		GameObject.Destroy(c.gameObject);
		pool.Remove(uid);
		return ;
	}
	public static void Clear(int uid) {

	}
}
