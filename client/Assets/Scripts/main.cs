using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class main : MonoBehaviour {
	// Use this for initialization

	void Switch() {
		StateManager.Instance.SwitchState("LoginState");
	}
	void Start () {
		Module.Camera.main.gameObject.SetActive(false);
		DB.DB.Load();
		var login = DB.DB.IpConfig.Get("login");
		NetInstance.Login.Connect(login.IP, login.Port, Switch);
	}

	// Update is called once per frame
	void Update () {
		NetInstance.Update();
	}
}
