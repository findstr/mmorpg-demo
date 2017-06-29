using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StateManager {

	private static StateManager inst = null;
	private GameState currentState = null;
	private Dictionary<string, GameState> pool = new Dictionary<string, GameState>();

	public static StateManager Instance {
		get {
			if (inst == null)
				inst = new StateManager();
			return inst;
		}
	}

	public void SwitchState(string name) {
		GameState state= null;
		if (currentState) {
			currentState.OnLeave();
			currentState.gameObject.SetActive(false);
		}
		if (pool.ContainsKey(name))
			state = pool[name];
		if (state == null) {
			GameObject obj = Resources.Load("Prefabs/" + name, typeof(GameObject)) as GameObject;
			obj = GameObject.Instantiate(obj) as GameObject;
			Debug.Assert(obj != null);
			state = obj.GetComponent<GameState>();
			pool[name] = state;
			state.OnEnter();
		} else {
			state.gameObject.SetActive(true);
			state.OnEnter();
		}
		currentState = state;
		return ;
	}

}
