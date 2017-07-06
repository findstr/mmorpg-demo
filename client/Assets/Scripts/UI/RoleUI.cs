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
		role_name.text = Module.Role.name;
		role_level.text = Module.Role.level.ToString();
		role_hp_bar.value = Module.Role.hp;
		role_hp_text.text = Module.Role.hp.ToString() + "/100";
	}

}
