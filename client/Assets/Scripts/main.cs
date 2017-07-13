using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class main : MonoBehaviour {

	//public string login_addr;
	//public int login_port;
	//public string gate_addr;
	//public int gate_port;

	void Awake() {
		//GameConfig.login_addr = login_addr;
		//GameConfig.gate_addr = gate_addr;
	}

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
