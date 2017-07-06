using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LeftUI : MonoBehaviour {
	public Button role_bag;
	void Start() {
		role_bag.onClick.AddListener(ShowBag);
	}
	void ShowBag() {
		Module.UI.bag.Show();
	}
}

