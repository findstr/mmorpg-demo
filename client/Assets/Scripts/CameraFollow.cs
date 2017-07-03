using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow {
	private Vector3 camera_pos;
	private Character follow_target;

	public void Attach(Character c) {
		follow_target = c;
		Camera main = GameData.mainCamera;
		//main.transform.rotation = GameConfig.main_camerarot;
		main.transform.position = follow_target.transform.position + GameConfig.main_cameraoffset;
		main.transform.LookAt(follow_target.transform);
	}

	public void OnUpdate() {
		if (follow_target == null)
			return ;
		Camera main = GameData.mainCamera;
		main.transform.position = follow_target.transform.position + GameConfig.main_cameraoffset;
		main.transform.LookAt(follow_target.transform);
		/*
		var pos = follow_target.transform.position;
		var rot = follow_target.transform.localRotation;

		var src_rot = maincamera.transform.localRotation;
		var dst_rot = rot * Quaternion.Euler(follow_target.transform.rotation.eulerAngles.x, 0.0f, 0.0f);
		maincamera.transform.localRotation = Quaternion.Slerp(src_rot, dst_rot, 0.5f);
		maincamera.transform.position = pos;
		maincamera.transform.position += maincamera.transform.rotation * camera_pos;
		*/
	}
}
