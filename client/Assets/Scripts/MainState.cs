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
				Module.Role.Basic.name,
				Module.Role.Basic.hp,
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
		Module.Role.Basic.hp = ack.hp;
		Module.UI.role.RefreshRole();
	}

	void ack_movepoint(int err, wire obj) {
		Debug.Assert(err == 0);
		a_movepoint ack = (a_movepoint)obj;
		var c = CharacterManager.Get(ack.uid);
		var src = Vector3.zero;
		var dst = Vector3.zero;
		Tool.ToNative(ref src, ack.src_coord_x, ack.src_coord_z);
		Tool.ToNative(ref dst, ack.dst_coord_x, ack.dst_coord_z);
		Debug.Log("[MainState] AckMovePoint:" + ack.uid);
		c.MovePoint(src, dst);
	}

	void ack_movediff(int err, wire obj) {
		a_movediff ack = (a_movediff)obj;
		for (int i = 0; i < ack.enter.Length; i++) {
			var p = ack.enter[i];
			var src = Vector3.zero;
			Tool.ToNative(ref src, p.coord_x, p.coord_z);
			CharacterManager.Create(p.uid, Tool.tostring(p.name), p.hp, src);
		}
		for (int i = 0; i < ack.leave.Length; i++)
			CharacterManager.Remove(ack.leave[i]);
	}

	void ack_moveenter(int err, wire obj) {
		a_moveenter ack = (a_moveenter)obj;
		Vector3 src = new Vector3();
		Tool.ToNative(ref src, ack.coord_x, ack.coord_z);
		CharacterManager.Create(ack.uid, Tool.tostring(ack.name), ack.hp, src);
	}

	void ack_moveleave(int err, wire obj) {
		a_moveleave ack = (a_moveleave)obj;
		CharacterManager.Remove(ack.uid);
	}

	void ack_attack(int err, wire o) {
		a_attack ack = (a_attack) o;
		var atk = CharacterManager.Get(ack.attacker);
		var target = CharacterManager.Get(ack.target);
		if (atk == null || target == null)
			return ;
		GameObject obj = Tool.InstancePrefab("Effect/EffectAtk");
		EffectAtk effect = obj.GetComponent<EffectAtk>();
		effect.SRC = atk.gameObject;
		effect.DST = target.gameObject;
		effect.Fire();
		target.HP = ack.targethp;
		Debug.Log("TargetHP:" + target.HP);
		return ;
	}

	//////////inherit

	void Awake() {
		Module.Misc.tool = GetComponent<GameTool>();
	}

	void Start() {
		OnEnter();
		a_itemuse itemuse = new a_itemuse();
		a_movepoint movepoint = new a_movepoint();
		a_movediff movediff = new a_movediff();
		a_moveenter moveenter = new a_moveenter();
		a_moveleave moveleave = new a_moveleave();
		a_attack attack = new a_attack();
		Register(itemuse, ack_itemuse);
		Register(movepoint, ack_movepoint);
		Register(movediff, ack_movediff);
		Register(moveenter, ack_moveenter);
		Register(moveleave, ack_moveleave);
		Register(attack, ack_attack);
	}

	void FixedUpdate() {
		OnUpdate();
	}

}
