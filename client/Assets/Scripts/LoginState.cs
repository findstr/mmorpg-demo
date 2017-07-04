using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using client_zproto;
using zprotobuf;

public class LoginState : GameState {
	public InputField user_name;
	public InputField user_passwd;
	public Button login_btn;
	public Button register_btn;

	public override void OnEnter() {
		Debug.Log("OnEnter");
	}

	public override void OnLeave() {
		Debug.Log("OnLeave");
	}
	public override string Name() {
		return "LoginState";
	}

	void on_register() {
		r_accountcreate req = new r_accountcreate();
		byte[] str = Tool.sha1(user_passwd.text);
		req.user = Encoding.Default.GetBytes(user_name.text);
		req.passwd = str;
		NetInstance.Login.Send(req);
		Debug.Log("[LoginState] Register:" + user_name.text + ":" + BitConverter.ToString(str));
		return ;
	}

	void on_login() {
		r_accountchallenge req = new r_accountchallenge();
		NetInstance.Login.Send(req);
		Debug.Log("[LoginState] Challenge");
	}


	// Use this for initialization
	void Start () {
		user_name.text = "findstr";
		user_passwd.text = "asdfg";
		//event
		register_btn.onClick.AddListener(on_register);
		login_btn.onClick.AddListener(on_login);
		//protocol
		a_accountcreate create = new a_accountcreate();
		a_accountchallenge challenge = new a_accountchallenge();
		a_accountlogin accountlogin = new a_accountlogin();
		a_gatelogin gatelogin = new a_gatelogin();
		Register(create, ack_create);
		Register(challenge, ack_challenge);
		Register(accountlogin, ack_accountlogin);
		Register(gatelogin, ack_gatelogin);
	}

	/////////////////protocol
	void ack_create(int err, wire obj) {
		a_accountcreate ack = (a_accountcreate) obj;
		Debug.Log("[LoginState] Create:" + ack.uid);
	}

	void ack_challenge(int err, wire obj) {
		a_accountchallenge ack = (a_accountchallenge)obj;
		Debug.Log("[LoginState] ack_challenge randomkey:" + ack.randomkey);
		string str = user_passwd.text;
		byte[] passwd = Tool.sha1(str);
		byte[] hash = Tool.hmac(passwd, Encoding.Default.GetString(ack.randomkey));
		r_accountlogin req = new r_accountlogin();
		req.gateid = 1;
		req.user = Encoding.Default.GetBytes(user_name.text);
		req.passwd = hash;
		NetInstance.Login.Send(req);
	}

	void ack_accountlogin(int err, wire obj) {
		a_accountlogin ack = (a_accountlogin)obj;
		Debug.Log("[LoginState] ack_accountlogin err:" + err + "uid:" + ack.uid);
		if (err == 0)
			Module.Role.uid = ack.uid;
		r_gatelogin req = new r_gatelogin();
		req.uid = ack.uid;
		req.token = ack.token;
		NetInstance.Gate.Send(req);
	}
	void ack_gatelogin(int err, wire obj) {
		Debug.Log("[LoginState] GateLogin:" + err);
		if (err == 0)
			StateManager.Instance.SwitchState("SelectState");
	}
}
