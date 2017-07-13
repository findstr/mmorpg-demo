using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class main : MonoBehaviour {
	// Use this for initialization
	void Start () {
		Module.Camera.main.gameObject.SetActive(false);
		StateManager.Instance.SwitchState("LoginState");
		DB.DB.Load();
		var login = DB.DB.IpConfig.Get("login");
		var gate = DB.DB.IpConfig.Get("gate");

		NetInstance.Login.Connect(login.IP, login.Port);
		NetInstance.Gate.Connect(gate.IP, gate.Port);
	}

	// Update is called once per frame
	void Update () {
		NetInstance.Update();
	}
}
