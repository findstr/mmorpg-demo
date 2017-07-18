using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RoleUI : MonoBehaviour {
	public Text role_name;
	public Text role_level;
	public Text role_hp_text;
	public Slider role_hp_bar;
	public Text role_mp_text;
	public Slider role_mp_bar;
	public Text role_exp_text;
	public Slider role_exp_bar;

	void Awake() {
		Module.UI.role = this;
	}

	public void RefreshRole() {
		var xml = DB.DB.RoleLevel.Get(Module.Role.Basic.level);
		var HP = xml.Hp;
		var MP = xml.Mp;
		var EXP = xml.Exp;
		role_name.text = Module.Role.Basic.name;
		role_level.text = Module.Role.Basic.level.ToString();
		role_hp_bar.value = Module.Role.Basic.hp / HP;
		role_hp_text.text = Module.Role.Basic.hp.ToString() + "/" + HP.ToString();
		role_mp_bar.value = Module.Role.Basic.mp / MP;
		role_mp_text.text = Module.Role.Basic.mp.ToString() + "/" + MP.ToString();
		role_exp_bar.value = Module.Role.Basic.exp / EXP;
		role_exp_text.text = Module.Role.Basic.exp.ToString() + "/" + EXP.ToString();
	}

}
