using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using zprotobuf;
using client_zproto;
public class SelectState : GameState {

	public GameObject role;
	public Text caption_name;
	public Text role_title;
	public InputField role_name;
	public Button role_create;
	public Button role_start;
	public Button return_btn;

	//////ui
	void disableUI() {
		caption_name.gameObject.SetActive(false);
		role_name.gameObject.SetActive(false);
		role_create.gameObject.SetActive(false);
	}
	void createUI() {
		Debug.Log("[SelectState] createUI");
		role_title.text = "创建角色";
		role_name.interactable = true;
		role_name.readOnly = false;
		role_create.gameObject.SetActive(true);
		role_start.gameObject.SetActive(false);
	}
	void showUI() {
		Debug.Log("[SelectState] showUI");
		role_title.text = "角色展示";
		role_start.gameObject.SetActive(true);
		role_create.gameObject.SetActive(false);
		caption_name.gameObject.SetActive(true);
		role_name.gameObject.SetActive(true);
		role_name.readOnly = true;
		role_name.interactable = false;
	}

	void eventUI() {
		role_create.onClick.AddListener(on_create);
		role_start.onClick.AddListener(on_start);
		return_btn.onClick.AddListener(on_return);
	}

	void on_create() {
		r_rolecreate req = new r_rolecreate();
		Debug.Log("[SelectState] CreateRole:" + role_name.text);
		req.name = Tool.tobytes(role_name.text);
		NetInstance.Gate.Send(req);
	}
	void on_start() {
		Debug.Log("State Start");
		StateManager.Instance.SwitchState("MainState");
	}

	void on_return() {
		Module.UI.mb.Show("你确定要返回登陆界面吗? ", do_return);
	}
	void do_return() {
		Module.UI.mb.Show("正在返回登陆界面，请稍等...");
		StateManager.Instance.SwitchState("LoginState");
	}

	private bool register_proto = false;
	void try_register() {
		if (register_proto)
			return ;
		register_proto = true;
		a_roleinfo roleinfo = new a_roleinfo();
		a_rolecreate rolecreate = new a_rolecreate();
		Register(roleinfo, ack_roleinfo);
		Register(rolecreate, ack_rolecreate);
	}

	///////state machine
	public override void OnEnter() {
		Module.UI.mb.Hide();
		disableUI();
		showUI();
		try_register();
		var offset = new Vector3(0.0f, 1.25f, -2.4f);
		Debug.Log("[SelectState]GetRoleInfo");
		Module.Camera.main.gameObject.SetActive(true);
		Module.Camera.main.transform.position = role.transform.position + offset;
		Module.Camera.main.transform.rotation = Quaternion.Euler(10.0f, 2.0f, -2.0f);

		//protocol
		r_roleinfo req = new r_roleinfo();
		NetInstance.Gate.Send(req);
	}

	public override void OnLeave() {
		NetInstance.Login.Close();
		NetInstance.Gate.Close();
		Module.UI.mb.Hide();
	}

	public override string Name() {
		return "SelectState";
	}


	///////inherit
	void Awake() {
		eventUI();
	}
	void Start() {
		try_register();
		Debug.Log("[MainState] Start!");
	}

	private int mouseId = Mouse.NONE;
	private Vector3 lastPosition;
	void Update() {
		int id = Mouse.GetDown();
		if (id != Mouse.NONE) {
			Vector3 pos = Mouse.GetPosition(id);
			if (mouseId == Mouse.NONE)
				lastPosition = pos;
			var delta = lastPosition.x - pos.x;
			Quaternion rot = Quaternion.Euler(0.0f, delta / GameConfig.select_rotspeed, 0.0f);
			role.transform.rotation *= rot;
			lastPosition = pos;
		}
		mouseId = id;
	}

	////////////protocol
	private void ack_roleinfo(int err, wire obj) {
		Debug.Log("RoleInfo");
		a_roleinfo ack = (a_roleinfo)obj;
		if (err == 0) {
			showUI();
			Module.Role.Basic.name = Tool.tostring(ack.name);
			Module.Role.Basic.exp = ack.exp;
			Module.Role.Basic.level = ack.level;
			Module.Role.Basic.gold = ack.gold;
			Module.Role.Basic.hp = ack.hp;
			Module.Role.Prop.atk = ack.prop.atk;
			Module.Role.Prop.def = ack.prop.def;
			Module.Role.Prop.matk = ack.prop.matk;
			Module.Role.Prop.mdef = ack.prop.mdef;
			Debug.Log("SetBag:" + ack.bag);
			Tool.ToNative(ref Module.Role.bag, ack.bag);
			role_name.text = Module.Role.Basic.name;
			Debug.Log("RoleInfoName:" + Module.Role.Basic.name + ":" + Module.Role.Basic.hp);
		} else {
			createUI();
		}
		Debug.Log("RoleInfo:" + err);
	}
	private void ack_rolecreate(int err, wire obj) {
		a_rolecreate ack = (a_rolecreate)obj;
		if (err == 0) {
			showUI();
			Module.Role.Basic.name = Tool.tostring(ack.name);
			Module.Role.Basic.exp = ack.exp;
			Module.Role.Basic.level = ack.level;
			Module.Role.Basic.gold = ack.gold;
			Module.Role.Basic.hp = ack.hp;
			Module.Role.Prop.atk = ack.prop.atk;
			Module.Role.Prop.def = ack.prop.def;
			Module.Role.Prop.matk = ack.prop.matk;
			Module.Role.Prop.mdef = ack.prop.mdef;
			Debug.Log("SetBag:" + ack.bag);
			Tool.ToNative(ref Module.Role.bag, ack.bag);
			role_name.text = Module.Role.Basic.name;
		}
		Debug.Log("RoleCreate:" + err);
	}

}

