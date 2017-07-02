using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class main : MonoBehaviour {

	public string login_addr;
	public int login_port;
	public string gate_addr;
	public int gate_port;

	void Awake() {
		GameConfig.login_addr = login_addr;
		GameConfig.gate_addr = gate_addr;
	}

	// Use this for initialization
	void Start () {
		GameData.mainCamera.gameObject.SetActive(false);
		NetInstance.Login.Connect(login_addr, login_port);
		NetInstance.Gate.Connect(gate_addr, gate_port);
		StateManager.Instance.SwitchState("LoginState");
		DB.DB.Load();
	}

	// Update is called once per frame
	void Update () {
		NetInstance.Update();
	}
}
