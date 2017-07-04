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
		main.transform.position = Vector3.Slerp(src, pos, 0.1f);
		main.transform.LookAt(follow_target.transform);
	}
}
