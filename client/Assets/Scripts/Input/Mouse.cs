using UnityEngine;
public class Mouse {
	public const int NONE = 1000;
#if UNITY_EDITOR
	static public int GetDown() {
		if (Input.GetMouseButton(0))
			return 0;
		else if (Input.GetMouseButton(1))
			return 1;
		else if (Input.GetMouseButton(2))
			return 2;
		else
			return NONE;
	}
	static public Vector3 GetPosition(int id) {
		return Input.mousePosition;
	}
#else
	static public int GetDown() {
		if (Input.touchCount == 0)
			return NONE;
		return 0;
	}
	static public Vector3 GetPosition(int id) {
		return Input.touches[id].position;
	}
#endif

}
