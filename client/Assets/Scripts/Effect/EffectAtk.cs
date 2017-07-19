using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectAtk : MonoBehaviour {
	public GameObject particle_run;
	public GameObject particle_hit;
	private int stage = 0;
	private GameObject particle;
	private float timestage1;
	private float timestage2;
	private Vector3 src_pos;
	private Quaternion src_rot;
	private Vector3 dst_pos;
	private Quaternion dst_rot;

	public GameObject SRC {
		set {
			src_pos = value.transform.position;
			src_rot = value.transform.rotation;
		}
	}
	public GameObject DST {
		set {
			dst_pos = value.transform.position;
			dst_rot = value.transform.rotation;
		}
	}

	public void Fire() {
		stage = 1;
		timestage1 = Time.time;
		particle = Instantiate(particle_run, src_pos, src_rot);
	}

	void UpdateStage1() {
		float delta = Time.time - timestage1;
		if (delta > 1.0f) {
			timestage2 = Time.time;
			Destroy(particle);
			particle = Instantiate(particle_hit, dst_pos, dst_rot);
			stage = 2;
		} else {
			particle.transform.position = Vector3.Lerp(src_pos,
					dst_pos, delta / 1.0f);
		}
	}

	void UpdateStage2() {
		float delta = Time.time - timestage2;
		if (delta < 0.5f)
			return ;
		Destroy(particle);
		Destroy(gameObject);
	}

	void FixedUpdate() {
		switch (stage) {
		case 0:
			return ;
		case 1:
			UpdateStage1();
			break;
		case 2:
			UpdateStage2();
			break;
		}
	}
}
