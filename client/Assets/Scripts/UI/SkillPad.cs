using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using client_zproto;

public class SkillPad: MonoBehaviour {
	public Button skill1;
	public GameObject src;
	public GameObject dst;
	void Start () {
		skill1.onClick.AddListener(Skill1);
	}

	void Skill1() {
		var hit = CharacterManager.AutoAim(Module.Role.uid, 10.0f);
		Debug.Log("Skill1:" + hit);
		if (hit == null)
			return ;
		r_attack atk = new r_attack();
		atk.skillid = 10000000;
		atk.target = hit.UID;
		NetInstance.Gate.Send(atk);
	}
}

