using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class main : MonoBehaviour {
	// Use this for initialization
	void Start () {
		Module.Camera.main.gameObject.SetActive(false);
		StateManager.Instance.SwitchState("LoginState");
		DB.DB.Load();
	}

	// Update is called once per frame
	void Update () {
		NetInstance.Update();
	}
}
