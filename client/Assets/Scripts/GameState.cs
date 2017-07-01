using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using client_zproto;
using zprotobuf;

public abstract class GameState : MonoBehaviour {
	private a_error @a_error = new a_error();
	private Dictionary<int, cb_t> protocol_cb = new Dictionary<int, cb_t>();
	private void ack_error(int err, wire obj) {
		a_error errobj = (a_error)obj;
		int cmd = errobj.cmd;
		int errno = errobj.err;
		if (!protocol_cb.ContainsKey(cmd)) {
			Debug.Log("[NetProtocol] can't has handler of cmd[" + cmd + "]");
			return ;
		}
		cb_t cb = protocol_cb[cmd];
		cb(errno, null);
		return ;
	}

	//////// public interface
	public delegate void cb_t(int err, wire obj);
	abstract public string Name();
	abstract public void OnEnter();
	abstract public void OnLeave();
	virtual public void OnUpdate() {}

	public GameState() {
		Register(@a_error, ack_error);
	}

	public void Register(wire obj, cb_t cb) {
		int cmd = obj._tag();
		NetInstance.Login.Register(obj);
		NetInstance.Gate.Register(obj);
		Debug.Assert(!protocol_cb.ContainsKey(cmd));
		protocol_cb[cmd] = cb;
	}

	public void Event(NetProtocol.event_cb_t open, NetProtocol.event_cb_t close) {
		NetInstance.Gate.Event(open, close);
	}

	public void Dispatch(int cmd, wire obj) {
		if (!protocol_cb.ContainsKey(cmd)) {
			Debug.Log(Name() + " Don't Process Cmd:" + cmd);
			return ;
		}
		var cb = protocol_cb[cmd];
		cb(0, obj);
	}
}

