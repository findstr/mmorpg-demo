using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityManager {
	private static Dictionary<int, Character> pool = new Dictionary<int, Character>();
	public static Character CreateCharacter(int uid, string name, int hp, Vector3 pos) {
		if (pool.ContainsKey(uid))
			return pool[uid];
		var obj = Tool.InstancePrefab("Character/Character01", pos, Quaternion.identity);
		Debug.Assert(obj);
		Character c = obj.GetComponent<Character>();
		pool[uid] = c;
		c.Name = name;
		c.HP = hp;
		c.UID = uid;
		return c;
	}
	public static Character GetCharacter(int uid) {
		if (pool.ContainsKey(uid))
			return pool[uid];
		return null;
	}
	public static Character AutoAimCharacter(int uid, float radius) {
		var atk = GetCharacter(uid);
		foreach (KeyValuePair<int, Character> entry in pool) {
			if (entry.Value == atk)
				continue;
			float dist = Vector3.Distance(atk.Position, entry.Value.Position);
			Debug.Log("Dist:" + dist);
			if (dist < radius)
				return entry.Value;
		}
		return null;
	}
	public static void RemoveCharacter(int uid) {
		var c = GetCharacter(uid);
		if (c == null)
			return ;
		GameObject.Destroy(c.gameObject);
		pool.Remove(uid);
		return ;
	}
	public static void ClearCharacter() {
		foreach (KeyValuePair<int, Character> entry in pool)
			GameObject.Destroy(entry.Value.gameObject);
		pool.Clear();
	}
}
