using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainState : GameState {
	private Character role;
	private MoveController controller;
	private CameraFollow follow = new CameraFollow();

	public override void OnEnter() {
		var obj = Tool.InstancePrefab("Character01");
		role = obj.GetComponent<Character>();
		Debug.Assert(role != null);
		controller = new MoveController(role);
		follow.Attach(role);
	}

	public override void OnLeave() {
		controller = null;
	}

	public override string Name() {
		return "MainState";
	}

	public override void OnUpdate() {
		if (controller != null)
			controller.OnUpdate();
		else
			Debug.Log("Controller:" + controller);
		if (follow != null)
			follow.OnUpdate();
	}

	//////////inherit

	void Start() {

	}

	void FixedUpdate() {
		OnUpdate();
	}

}
