using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.AI;
using client_zproto;

public class MoveController {
	private Character role;
	private Vector3 last_position;
	private bool KeyMove() {
		bool effect = false;
		var dst = role.transform.position;
		var rot = role.transform.localRotation;
		float forward = 0.0f;
		float turn = 0.0f;
		if (Input.GetKey(KeyCode.W)) {
			forward = Time.deltaTime * GameConfig.main_runspeed;
			effect = true;
		} else if (Input.GetKey(KeyCode.S)) {
			forward = -Time.deltaTime * GameConfig.main_runspeed;
			effect = true;
		}

		if (Input.GetKey(KeyCode.A)) {
			turn = -Time.deltaTime * GameConfig.main_turnspeed;
			effect = true;
		} else if (Input.GetKey(KeyCode.D)) {
			turn = Time.deltaTime * GameConfig.main_turnspeed;
			effect = true;
		}
		if (effect == false)
			return effect;
		//character rotation
		Quaternion rotY = Quaternion.Euler(0.0f, turn, 0.0f);
		rot = rot * rotY;
		//position
		Vector3 move = new Vector3(0.0f, 0.0f, forward);
		move = rot * move;
		dst += move;
		//sync
		role.SetShadow(dst, rot);
		return effect;
	}

	private int lastClick = Mouse.NONE;
	private bool ClickMove() {
		if (!Module.Control.input3d)
			return false;
		int id = Mouse.GetDown();
		if (!(lastClick == Mouse.NONE && id != Mouse.NONE)) {
			lastClick = id;
			return false;
		}

		RaycastHit hitInfo;
		lastClick = id;
		Camera main = Module.Camera.main;
		var pos = Mouse.GetPosition(id);
		var ray = main.ScreenPointToRay(pos);
		Debug.DrawRay(ray.origin, ray.direction *20, Color.yellow);
		if (!Physics.Raycast(ray, out hitInfo, Mathf.Infinity, 1 << 9))
			return false;
		var hitObj = hitInfo.collider.gameObject;
		if (hitObj.tag != "Terrian")
			return false;
		Tool.PlayParticle(GameConfig.move.click_particle, hitInfo.point, 0.3f);
		role.MovePoint(role.transform.position, hitInfo.point);
		//notify Net
		r_movepoint movepoint = new r_movepoint();
		movepoint.src_coord_x = role.transform.position.x;
		movepoint.src_coord_z = role.transform.position.z;
		movepoint.dst_coord_x = hitInfo.point.x;
		movepoint.dst_coord_z = hitInfo.point.z;
		NetInstance.Gate.Send(movepoint);
		Debug.Log("MovePoint");
		return true;
	}

	///interface
	public MoveController(Character c) {
		Debug.Assert(c != null);
		role = c;
		last_position = role.transform.position;
		last_position.y = 0;
		return ;
	}

	void ServerUpdate() {
		var pos = role.transform.position;
		pos.y = 0;
		if (Vector3.Distance(pos, last_position) < 1.0f)
			return ;
		last_position = pos;
		r_movesync sync = new r_movesync();
		sync.coord_x = pos.x;
		sync.coord_z = pos.z;
		NetInstance.Gate.Send(sync);
		Debug.Log("ServerUpdate" + pos);
	}

	public void OnUpdate() {
		ClickMove();
		//KeyMove();
		ServerUpdate();
		Module.Role.pos = role.transform.position;
		Module.UI.coord.Refresh();
	}
}
