using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using zprotobuf;
using client_zproto;

public class MainState : GameState {
	private bool alreadyenter = false;
	private Character role;
	private MoveController controller;
	private CameraFollow follow = new CameraFollow();

	public override void OnEnter() {
		if (alreadyenter)
			return ;
		alreadyenter = true;
		Module.Misc.state = this;
		role = CharacterManager.Create(Module.Role.uid,
				Module.Role.name,
				Module.Role.hp,
				Module.Role.pos);
		Debug.Assert(role != null);
		controller = new MoveController(role);
		follow.Attach(role);
		Module.UI.role.RefreshRole();
		/*
		var i = new DB.IdCount();
		i.id = 10000;
		i.count = 3;
		Module.Role.bag[10000] = i;
		i.id = 10001;
		Module.Role.bag[10001] = i;
		*/
		DB.DB.Load();
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

	///////////protocol
	void ack_itemuse(int err, wire obj) {
		if (err != 0) //TODO: show messagebox
			return ;
		a_itemuse ack = (a_itemuse) obj;
		Module.Role.hp = ack.hp;
		Module.UI.role.RefreshRole();
	}

	//////////inherit

	void Awake() {
		Module.Misc.tool = GetComponent<GameTool>();
	}

	void Start() {
		OnEnter();
		a_itemuse itemuse = new a_itemuse();
		Register(itemuse, ack_itemuse);
	}

	void FixedUpdate() {
		OnUpdate();
	}

}
