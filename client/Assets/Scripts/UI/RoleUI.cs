using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RoleUI : MonoBehaviour {
	public Text role_name;
	public Text role_level;
	public Text role_hp_text;
	public Slider role_hp_bar;

	void Awake() {
		Module.UI.role = this;
	}

	public void RefreshRole() {
		role_name.text = Module.Role.Basic.name;
		role_level.text = Module.Role.Basic.level.ToString();
		role_hp_bar.value = Module.Role.Basic.hp;
		role_hp_text.text = Module.Role.Basic.hp.ToString() + "/100";
	}

}
