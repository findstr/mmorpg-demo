using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using client_zproto;

using zprotobuf;

public abstract class GameState : MonoBehaviour {
	abstract public void OnEnter();
	abstract public void OnLeave();
}


