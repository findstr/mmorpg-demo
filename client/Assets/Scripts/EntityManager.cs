using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityManager {
	private static Dictionary<int, Character> CP = new Dictionary<int, Character>();
	private static Dictionary<int, NPC> NP = new Dictionary<int, NPC>();

	private static Character create(string model, int uid, string name, int hp, Vector3 pos) {
		var obj = Tool.InstancePrefab(model, pos, Quaternion.identity);
		Debug.Assert(obj);
		Character c = obj.GetComponent<Character>();
		CP[uid] = c;
		c.Name = name;
		c.HP = hp;
		c.UID = uid;
		return c;
	}

	public static Character CreatePC(int uid, string name, int hp, Vector3 pos) {
		Debug.Log("[EntityManager] CreatePC:" + uid);
		if (CP.ContainsKey(uid))
			return CP[uid];
		return create("Character/Character01", uid, name, hp, pos);
	}

	public static Character CreateNPC(int uid, string name, int hp, Vector3 pos, string model) {
		Debug.Log("[EntityManager] CreateNPC:" + uid);
		if (NP.ContainsKey(uid))
			return CP[uid];
		var c = create("NPC/" + model, uid, name, hp, pos);
		var npc = c.gameObject.GetComponent<NPC>();
		Debug.Assert(npc);
		NP[uid] = npc;
		return c;
	}

	public static Character GetCharacter(int uid) {
		if (CP.ContainsKey(uid))
			return CP[uid];
		return null;
	}
	public static Character AutoAimCharacter(int uid, float radius) {
		var atk = GetCharacter(uid);
		foreach (KeyValuePair<int, Character> entry in CP) {
			if (entry.Value == atk)
				continue;
			float dist = Vector3.Distance(atk.Position, entry.Value.Position);
			if (dist < radius)
				return entry.Value;
		}
		return null;
	}
	public static void RemoveCharacter(int uid) {
		Debug.Log("[EntityManager]RemoveCharacter:" + uid);
		var c = GetCharacter(uid);
		if (c == null)
			return ;
		GameObject.Destroy(c.gameObject);
		CP.Remove(uid);
		NP.Remove(uid);
		return ;
	}
	public static void ClearCharacter() {
		foreach (KeyValuePair<int, Character> entry in CP)
			GameObject.Destroy(entry.Value.gameObject);
		CP.Clear();
		NP.Clear();
	}
}
