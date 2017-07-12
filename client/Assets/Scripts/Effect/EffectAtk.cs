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
	private GameObject src;
	private GameObject dst;

	public GameObject SRC {
		set { src = value; }
	}
	public GameObject DST {
		set { dst = value; }
	}

	public void Fire() {
		stage = 1;
		timestage1 = Time.time;
		particle = Instantiate(particle_run, src.transform.position, src.transform.rotation);
	}

	void UpdateStage1() {
		float delta = Time.time - timestage1;
		if (delta > 1.0f) {
			timestage2 = Time.time;
			Destroy(particle);
			particle = Instantiate(particle_hit, dst.transform.position, dst.transform.rotation);
			stage = 2;
		} else {
			particle.transform.position = Vector3.Lerp(src.transform.position,
					dst.transform.position, delta / 1.0f);
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
