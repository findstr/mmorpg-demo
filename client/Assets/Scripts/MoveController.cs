using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveController {
	private Character role;
	public MoveController(Character c) {
		Debug.Assert(c != null);
		role = c;
	}

	public void OnUpdate() {
		var dst = role.transform.position;
		var rot = role.transform.localRotation;
		float forward = 0.0f;
		float turn = 0.0f;
		if (Input.GetKey(KeyCode.W))
			forward = Time.deltaTime * GameConfig.main_runspeed;
		else if (Input.GetKey(KeyCode.S))
			forward = -Time.deltaTime * GameConfig.main_runspeed;

		if (Input.GetKey(KeyCode.A)) {
			turn = -Time.deltaTime * GameConfig.main_turnspeed;
		} else if (Input.GetKey(KeyCode.D)) {
			turn = Time.deltaTime * GameConfig.main_turnspeed;
		}
		Vector3 move_pos;
		Quaternion move_rot;
		//character rotation
		Quaternion rotY = Quaternion.Euler(0.0f, turn, 0.0f);
		rot = rot * rotY;
		//position
		Vector3 move = new Vector3(0.0f, 0.0f, forward);
		move = rot * move;
		dst += move;

		role.SetShadow(dst, rot);
	}
}
