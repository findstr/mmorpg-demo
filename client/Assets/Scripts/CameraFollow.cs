using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow {
	private Character follow_target;

	public void Attach(Character c) {
		follow_target = c;
		Camera main = GameData.mainCamera;
		var pos = follow_target.transform.position;
		pos.y = 0;
		main.transform.position = pos + GameConfig.main_cameraoffset;
		main.transform.LookAt(follow_target.transform);
	}

	public void OnUpdate() {
		if (follow_target == null)
			return ;
		Camera main = GameData.mainCamera;
		var pos = follow_target.transform.position;
		pos.y = 0;
		pos += GameConfig.main_cameraoffset;
		var src = main.transform.position;
		Debug.Log("CameraY:" + pos + src);
		if (Mathf.Abs(pos.x - src.x) < 1.0f)
			pos.x = src.x;
		if (Mathf.Abs(pos.z - src.z) < 1.0f)
			pos.z = src.z;
		pos = Vector3.Slerp(src, pos, Time.deltaTime);
		pos.y = src.y;
		main.transform.position = pos;
		main.transform.LookAt(follow_target.transform);
	}
}
