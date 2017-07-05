using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CharacterUI : MonoBehaviour {
	public Slider role_hpbar;
	public Text role_name;
	public Vector3 role_hpbar_offset;
	public Vector3 role_name_offset;
	public float role_ui_scale_frac = 2.0f;
	public float role_ui_scale_min = 0.5f;
	public float role_ui_scale_max = 1.0f;

	private int hp = 100;
	public int HP {
		get { return hp; }
		set { hp = value; }
	}
	public string Name {
		get { return role_name.text; }
		set { role_name.text = value; }
	}
	private void checkSee(GameObject obj, Vector3 pos, float scale) {
		scale = Mathf.Clamp(scale, role_ui_scale_min, role_ui_scale_max);
		obj.transform.position = pos;
		obj.transform.localScale = scale * Vector3.one;
	}
	public void OnUpdate() {
		var uicamera = Module.Camera.ui;
		var maincamera = Module.Camera.main;
		if (uicamera == null)
			return ;
		float scale = role_ui_scale_frac / Vector3.Distance(transform.position, maincamera.transform.position);
		Vector3 hp_wpos = transform.position + role_hpbar_offset;
		var hp_uipos = maincamera.WorldToScreenPoint(hp_wpos);
		hp_uipos = uicamera.ScreenToWorldPoint(hp_uipos);
		checkSee(role_hpbar.gameObject, hp_uipos, scale);
		Vector3 name_wpos = transform.position + role_name_offset;
		var name_uipos = maincamera.WorldToScreenPoint(name_wpos);
		name_uipos = uicamera.ScreenToWorldPoint(name_uipos);
		checkSee(role_name.gameObject, name_uipos, scale);
	}
}
