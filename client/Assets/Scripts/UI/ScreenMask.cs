using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class ScreenMask : MonoBehaviour, IPointerDownHandler {
	public delegate void click_cb_t();
	click_cb_t click;
	public click_cb_t OnClick {
		set { click = value; }
	}
	public void Enable(bool b) {
		gameObject.SetActive(b);
	}
	//////////////////
	void Awake() {
		Module.UI.mask = this;
		gameObject.SetActive(false);
	}
	public void OnPointerDown(PointerEventData data) {
		if (click != null)
			click();
	}
}
