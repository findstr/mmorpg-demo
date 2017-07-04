using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveConfig {
	public string click_particle = "GreenCore";
}

public class GameConfig {
	static public string login_addr;
	static public string gate_addr;
	static public int login_port;
	static public int gate_port;
	static public int select_rotspeed = 1;
	static public float main_runspeed = 100.0f;
	static public float main_turnspeed = 100.0f;
	static public Vector3 main_cameraoffset = new Vector3(0.0f, 5.0f, -8.0f);
	static public Quaternion main_camerarot = Quaternion.Euler(0.0f, 0.0f, 0.0f);
	static public MoveConfig move = new MoveConfig();
}

