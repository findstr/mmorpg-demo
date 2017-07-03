using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class MoveController {

	private NavMeshAgent agent;
	private Character role;
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
		int id = Mouse.GetDown();
		if (!(lastClick == Mouse.NONE && id != Mouse.NONE)) {
			lastClick = id;
			return false;
		}
		RaycastHit hitInfo;
		lastClick = id;
		Camera main = GameData.mainCamera;
		var pos = Mouse.GetPosition(id);
		//pos.z = ui.nearClipPlane;
		//var uipos = ui.ScreenToWorldPoint(pos);
		var ray = main.ScreenPointToRay(pos);
		Debug.DrawRay(ray.origin, ray.direction *20, Color.yellow);
		if (!Physics.Raycast(ray, out hitInfo, Mathf.Infinity, 1 << 9))
			return false;
		var hitObj = hitInfo.collider.gameObject;
		if (hitObj.tag != "Terrian")
			return false;
		agent.SetDestination(hitInfo.point);
		Tool.PlayParticle(GameConfig.move.click_particle, hitInfo.point, 0.3f);
		return true;
	}

	private bool ClickUpdate() {
		var rot = role.transform.localRotation;
		role.SetShadow(agent.nextPosition, rot);
		return true;
	}

	///interface
	public MoveController(Character c) {
		Debug.Assert(c != null);
		role = c;
		agent = role.gameObject.GetComponent<NavMeshAgent>();
		agent.updatePosition = false;
		return ;
	}



	public void OnUpdate() {
		ClickMove();
		ClickUpdate();
		//KeyMove();
	}
}
