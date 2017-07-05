using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CanvasCamera : MonoBehaviour {
	void Start () {
		Canvas c = GetComponent<Canvas>();
		c.worldCamera = Module.Camera.ui;
	}
}
