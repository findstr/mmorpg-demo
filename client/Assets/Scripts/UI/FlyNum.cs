using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlyNum : MonoBehaviour {
	public float fly_speed = 10;
	public GameObject container;
	public Sprite[] numres;
	private Vector3 from;
	private Vector3 to;
	private void Create(int n) {
		var obj = Tool.InstancePrefab("Num/num" + n,
				container.transform.position,
				container.transform.rotation);
		obj.transform.SetParent(container.transform);
		obj.transform.localScale = Vector3.one * 100;
	}
	public void Fly(int num, Vector3 from, int h) {
		this.from = from;
		this.to = from;
		this.to.y += h;
		while (num > 0) {
			int n = num % 10;
			Create(n);
			n /= 10;
		}
	}

	void Start() {
		Fly(3, Vector3.one, 3);
	}

	void FixedUpdate () {
		Debug.Log("From" + from + to);
		if (from.y > to.y) {
			Destroy(gameObject);
			return;
		}
		var uicamera = Module.Camera.ui;
		var maincamera = Module.Camera.main;
		if (uicamera == null)
			return ;
		float scale = GameConfig.role_ui_scale_frac /
			Vector3.Distance(from, maincamera.transform.position);
		var uipos = maincamera.WorldToScreenPoint(from);
		uipos = uicamera.ScreenToWorldPoint(uipos);
		scale = Mathf.Clamp(scale, GameConfig.role_ui_scale_min, GameConfig.role_ui_scale_max);
		container.transform.position = uipos;
		container.transform.localScale = scale * Vector3.one;
		from.y += fly_speed * Time.deltaTime;
	}
}
