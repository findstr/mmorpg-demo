using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCamera : MonoBehaviour {
	void Awake() {
		Start();
	}

	// Use this for initialization
	void Start () {
		GameData.mainCamera = GetComponent<Camera>();
	}




	/////////////blur function
	[Range(0,4)]
	public int blurLoop = 3;
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;
	[Range(1, 8)]
	public int blurScale = 2;
	public Shader blurShader;
	public bool blurEnable;

	private Material blur_mat = null;
	private Material blurMat {
		get {
			if (blur_mat != null)
				return blur_mat;
			if (!checkSupport())
				return null;
			blur_mat = new Material(blurShader);
			blur_mat.hideFlags = HideFlags.DontSave;
			return blur_mat;
		}
	}

	public bool BlurEnable {
		set {
			blurEnable = value;
		}
	}

	private bool checkSupport() {
		return SystemInfo.supportsImageEffects;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		if (blurEnable == false || blurMat == null) {
			Graphics.Blit(src, dst);
			return ;
		}
		int rtW = src.width;
		int rtH = src.height;
		var ping = RenderTexture.GetTemporary(rtW, rtH, 0);
		var pong = RenderTexture.GetTemporary(rtW, rtH, 0);
		ping.filterMode = FilterMode.Bilinear;
		Graphics.Blit(src, ping);
		for (int i = 0; i < blurLoop; i++) {
			blurMat.SetFloat("_BlurSize", 1.0f + 1 * blurSpread);
			Graphics.Blit(ping, pong, blurMat, 0);
			Graphics.Blit(pong, ping, blurMat, 1);
		}
		Graphics.Blit(ping, dst);
		RenderTexture.ReleaseTemporary(ping);
		RenderTexture.ReleaseTemporary(pong);
	}
}
