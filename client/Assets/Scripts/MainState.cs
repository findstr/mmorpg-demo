using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI;
using zprotobuf;
using client_zproto;

public class MainState : GameState {
	private bool alreadyenter = false;
	private Character role;
	private MoveController controller;
	private CameraFollow follow = new CameraFollow();

	public Button return_btn;

	public override void OnEnter() {
		if (alreadyenter)
			return ;
		Module.UI.mb.Hide();
		alreadyenter = true;
		Module.Misc.state = this;
		role = EntityManager.CreateCharacter(Module.Role.uid,
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
		r_startgame req = new r_startgame();
		NetInstance.Gate.Send(req);
		DB.DB.Load();
	}

	public override void OnLeave() {
		Module.UI.mb.Hide();
		EntityManager.ClearCharacter();
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
		var c = EntityManager.GetCharacter(ack.uid);
		if (c == null)
			return ;
		var src = Vector3.zero;
		var dst = Vector3.zero;
		Tool.ToNative(ref src, ack.src_coord_x, ack.src_coord_z);
		Tool.ToNative(ref dst, ack.dst_coord_x, ack.dst_coord_z);
		Debug.Log("[MainState] AckMovePoint:" + ack.uid);
		c.MovePoint(src, dst);
	}

	void ack_movediff(int err, wire obj) {
		a_movediff ack = (a_movediff)obj;
		if (ack.enter != null) {
			for (int i = 0; i < ack.enter.Length; i++) {
				var p = ack.enter[i];
				var src = Vector3.zero;
				Tool.ToNative(ref src, p.coord_x, p.coord_z);
				string name;
				if (p.name == null)
					name = "我是怪";
				else
					name = Tool.tostring(p.name);
				EntityManager.CreateCharacter(p.uid, name, p.hp, src);
			}
		}
		if (ack.leave != null) {
			for (int i = 0; i < ack.leave.Length; i++)
				EntityManager.RemoveCharacter(ack.leave[i]);
		}
	}

	void ack_moveenter(int err, wire obj) {
		a_moveenter ack = (a_moveenter)obj;
		Vector3 src = new Vector3();
		Tool.ToNative(ref src, ack.coord_x, ack.coord_z);
		EntityManager.CreateCharacter(ack.uid, Tool.tostring(ack.name), ack.hp, src);
	}

	void ack_moveleave(int err, wire obj) {
		a_moveleave ack = (a_moveleave)obj;
		EntityManager.RemoveCharacter(ack.uid);
	}

	void ack_attack(int err, wire o) {
		a_attack ack = (a_attack) o;
		var atk = EntityManager.GetCharacter(ack.attacker);
		var target = EntityManager.GetCharacter(ack.target);
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

	void on_return() {
		Module.UI.mb.Show("你确定要返回选择角色界面吗? ", do_return);
	}
	void do_return() {
		Module.UI.mb.Show("正在返回选择角色界面，请稍等...");
		StateManager.Instance.SwitchState("SelectState");
	}

	void ack_gatekick(int err, wire obj) {
		Debug.Log("GateKick");
		StateManager.Instance.SwitchState("LoginState");
	}

	//////////inherit
	void Awake() {
		Module.Misc.tool = GetComponent<GameTool>();
		return_btn.onClick.AddListener(on_return);
	}

	void Start() {
		OnEnter();
		a_itemuse itemuse = new a_itemuse();
		a_movepoint movepoint = new a_movepoint();
		a_movediff movediff = new a_movediff();
		a_moveenter moveenter = new a_moveenter();
		a_moveleave moveleave = new a_moveleave();
		a_attack attack = new a_attack();
		a_gatekick kick = new a_gatekick();
		Register(itemuse, ack_itemuse);
		Register(movepoint, ack_movepoint);
		Register(movediff, ack_movediff);
		Register(moveenter, ack_moveenter);
		Register(moveleave, ack_moveleave);
		Register(attack, ack_attack);
		Register(kick, ack_gatekick);
	}

	void DebugGrid() {
		var src = Vector3.zero;
		var dst = Vector3.zero;
		dst.z = 100;
		for (int i = 0; i < 100; i += 10) {
			src.x = i;
			dst.x = i;
			Debug.DrawLine(src, dst, Color.white);
		}
		dst.x = 100;
		for (int j = 0; j < 10; j++) {
			src.z = j;
			dst.z = j;
			Debug.DrawLine(src, dst, Color.white);
		}
	}

	void FixedUpdate() {
		OnUpdate();
		DebugGrid();
	}

}
