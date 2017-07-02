using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class MainState : GameState {
	private bool alreadyenter = false;
	private Character role;
	private MoveController controller;
	private CameraFollow follow = new CameraFollow();

	public override void OnEnter() {
		if (alreadyenter)
			return ;
		alreadyenter = true;
		GameData.state = this;
		var obj = Tool.InstancePrefab("Character01");
		role = obj.GetComponent<Character>();
		Debug.Assert(role != null);
		controller = new MoveController(role);
		follow.Attach(role);
	}

	public override void OnLeave() {
		controller = null;
		alreadyenter = false;
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

	void Awake() {
		GameData.tool = GetComponent<GameTool>();
	}

	void Start() {
		OnEnter();
	}

	void FixedUpdate() {
		OnUpdate();
	}

}
