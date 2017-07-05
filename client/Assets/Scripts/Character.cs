using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shadow {
	public Vector3 pos;
	public Quaternion rot;
};

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(CapsuleCollider))]
public class Character : MonoBehaviour {
	//component
	private Rigidbody RB;
	private Animator animator;
	private CharacterUI UI;
	//data
	private int uid = -1;
	private Shadow shadow = new Shadow();

	public void SetShadow(Vector3 pos, Quaternion rot) {
		shadow.pos = pos;
		shadow.rot = rot;
		transform.localRotation = shadow.rot;
	}

	bool SetRun(float z) {
		if (z > 0.1f) {
			animator.SetBool("Run", true);
			animator.SetFloat("RunDir", 1.0f);
			return true;
		} else if (z < -0.1f) {
			animator.SetBool("Run", true);
			animator.SetFloat("RunDir", -1.0f);
			return true;
		}
		animator.SetBool("Run", false);
		animator.SetFloat("RunDir", 0.0f);
		return false;
	}

	void FixedAnimator() {
		var delta = transform.position;
		delta.y = 0;
		delta = shadow.pos - delta;
		var dir = transform.InverseTransformDirection(delta);
		SetRun(dir.z);
	}
	///////////property
	public string Name {
		get { return UI.Name; }
		set { UI.Name = value; }
	}
	public int HP {
		get { return UI.HP; }
		set { UI.HP = value; }
	}
	public int UID {
		get { return uid; }
		set { uid = value; }
	}

	////////////iherit
	void Awake() {
		RB = GetComponent<Rigidbody>();
		animator = GetComponent<Animator>();
		RB.constraints =
			RigidbodyConstraints.FreezeRotationX |
			RigidbodyConstraints.FreezeRotationY |
			RigidbodyConstraints.FreezeRotationZ;
		shadow.pos = transform.position;
		shadow.rot = transform.localRotation;
		UI = GetComponent<CharacterUI>();
	}

	void Start() {
		shadow.pos = transform.position;
		shadow.rot = transform.localRotation;
	}

	void OnAnimatorMove()
	{
		if (Time.deltaTime > 0.0f) {
			var src = transform.position;
			src.y = 0;
			var pos = Vector3.Slerp(src, shadow.pos, 0.1f);
			pos.y = transform.position.y;
			transform.position = pos;
		}
	}

	void FixedUpdate() {
		FixedAnimator();
		if (UI != null)
			UI.OnUpdate();
	}
}
