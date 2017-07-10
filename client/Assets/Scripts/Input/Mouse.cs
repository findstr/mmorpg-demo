using UnityEngine;
using UnityEngine.EventSystems;

public class Mouse {
	public const int NONE = 1000;
#if UNITY_EDITOR || UNITY_STANDALONE
	static public int GetDown() {
		int ret = NONE;
		if (Input.GetMouseButton(0))
			ret = 0;
		else if (Input.GetMouseButton(1))
			ret = 1;
		else if (Input.GetMouseButton(2))
			ret = 2;
		if (ret == NONE)
			return ret;
		if (EventSystem.current.IsPointerOverGameObject())
			return NONE;
		return ret;
	}
	static public Vector3 GetPosition(int id) {
		return Input.mousePosition;
	}
#else
	private int status = NONE;
	static public int GetDown() {
		if (Input.touchCount > 0) {
			var touch = Input.GetTouch(0);
			if (touch.phase != TouchPhase.Began)
				return status;
			if (EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId))
				status = NONE;
			status = 0;
		} else {
			status = NONE;
		}
		return status;
	}
	static public Vector3 GetPosition(int id) {
		return Input.touches[id].position;
	}
#endif

}
