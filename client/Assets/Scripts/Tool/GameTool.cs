using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameTool : MonoBehaviour {
	public GameObject InstancePrefab(string name, Vector3 pos, Quaternion rot) {
		GameObject obj = Resources.Load("Prefabs/" + name, typeof(GameObject)) as GameObject;
		Debug.Log("Instance:" + obj + name);
		obj = GameObject.Instantiate(obj, pos, rot) as GameObject;
		return obj;
	}

	public GameObject InstancePrefab(string name) {
		return InstancePrefab(name, Vector3.zero, Quaternion.identity);
	}

	private IEnumerator ParticleCo(string name, Vector3 pos, float sec) {
		var obj = InstancePrefab(name, pos, Quaternion.identity);
		yield return new WaitForSeconds(sec);
		Destroy(obj);
	}

	public void PlayParticle(string name, Vector3 pos, float sec) {
		StartCoroutine (ParticleCo("Particle/" + name, pos, sec));
	}
}
