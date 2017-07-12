using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MessageBox : MonoBehaviour {
    public Text mb_tt;
    public Button btn_ok;
    public Button btn_cl;
    public delegate void call();
    private call g_ok;
    private call g_cancel;

    void on_ok() {
        Hide();
        if (g_ok != null)
            g_ok();

        Debug.Log("message box, press OK !");
    }

    void on_cl() {
        Hide();
        if (g_cancel != null)
            g_cancel();

        Debug.Log("message box, press Cancel !");
    }

    public void Show(string str, call ok = null, call cancel = null) {
        mb_tt.text = str;
        g_ok = ok;
        g_cancel = cancel;

        if (Module.UI.mask) {
            Module.UI.mask.OnClick = Hide;
            Module.UI.mask.Enable(true);
            Module.UI.mask.gameObject.SetActive(true);
        }

        gameObject.SetActive(true);
    }

    public void Hide() {
        if (Module.UI.mask) {
            Module.UI.mask.OnClick = null;
            Module.UI.mask.Enable(false);
            Module.UI.mask.gameObject.SetActive(false);
        }

        gameObject.SetActive(false);
    }

    void Awake() {
        Module.UI.mb = this;
        Hide();
    }

	// Use this for initialization
	void Start () {
        btn_ok.onClick.AddListener(on_ok);
        btn_cl.onClick.AddListener(on_cl);
	}
}
