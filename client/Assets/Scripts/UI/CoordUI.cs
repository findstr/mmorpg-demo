using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CoordUI : MonoBehaviour {
	private Text text;
	void Awake() {
		text = GetComponent<Text>();
		Module.UI.coord = this;
	}

	public void Refresh() {
		text.text = "(" + (int)Module.Role.pos.x + ":" + (int)Module.Role.pos.z + ")";
	}
}
