using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BagItem : MonoBehaviour {
	public Image item_icon;
	public Text item_count;
	private int id;
	private int count;
	public int Id {
		get { return id; }
		set { id = value; }
	}

	public int Count {
		get { return count; }
		set {
			count = value;
			item_count.text = count.ToString();
		}
	}

	public int Show() {
		var item = DB.DB.Item.Get(id);
		var sprite = Resources.Load<Sprite>("Sprite/" + item.Icon);
		item_icon.sprite = sprite;
		return 0;
	}
	public void HightLight(bool enable) {

	}
}

