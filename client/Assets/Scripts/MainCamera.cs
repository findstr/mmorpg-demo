using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCamera : MonoBehaviour {
	void Awake() {
		Start();
	}

	// Use this for initialization
	void Start () {
		GameData.mainCamera = GetComponent<Camera>();
	}
}
