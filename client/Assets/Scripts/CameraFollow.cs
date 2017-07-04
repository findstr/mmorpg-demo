using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow {
	private Vector3 follow_pos;
	private Character follow_target;

	public void Attach(Character c) {
		follow_target = c;
		Camera main = GameData.mainCamera;
		var pos = follow_target.transform.position;
		pos.y = 0;
		follow_pos = follow_target.transform.position;
		main.transform.position = pos + GameConfig.main_cameraoffset;
		main.transform.LookAt(follow_target.transform);
	}

	public void OnUpdate() {
		if (follow_target == null)
			return ;
		Camera main = GameData.mainCamera;
		Tool.Filter(ref follow_pos, follow_target.transform.position, 0.1f);
		var pos = follow_pos;
		pos.y = 0;
		pos += GameConfig.main_cameraoffset;
		var src = main.transform.position;
		pos = Vector3.Slerp(src, pos, 0.1f);
		pos.y = src.y;
		main.transform.position = pos;
		//main.transform.LookAt(follow_pos);
	}
}
