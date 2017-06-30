using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using zprotobuf;
using client_zproto;
public class SelectState : GameState {

	public override void OnEnter() {
		r_roleinfo req = new r_roleinfo();
		NetInstance.Gate.Send(req);
		Debug.Log("GetRoleInfo");
	}

	public override void OnLeave() {

	}

	public override string Name() {
		return "SelectState";
	}

	public void Start() {
		a_roleinfo roleinfo = new a_roleinfo();
		Register(roleinfo, ack_roleinfo);
	}

	////////////protocol
	private void ack_roleinfo(int err, wire obj) {
		Debug.Log("RoleInfo:" + err);
	}

}

