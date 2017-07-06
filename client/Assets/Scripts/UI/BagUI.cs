using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BagUI : MonoBehaviour {
	public Text bag_detail;
	public GameObject bag_content;
	private Dictionary<int, BagItem> pool = new Dictionary<int, BagItem>();
	private BagItem item_select = null;
	private void createItem(int id, int count) {
		if (pool.ContainsKey(id))
			return ;
		var obj = Tool.InstancePrefab("UI/BagItem", bag_content.transform.position, bag_content.transform.rotation);
		obj.transform.SetParent(bag_content.transform);
		obj.transform.localScale = Vector3.one;
		var item = obj.GetComponent<BagItem>();
		pool[id] = item;
		item.Id = id;
		item.Count = count;
		EventTriggerListener.Get(obj).onClick = delegate(GameObject p) {
			var xml = DB.DB.Item.Get(id);
			if (xml == null)
				return ;
			bag_detail.text = xml.Desc;
			item_select = item;
		};
		item.Show();
	}

	public void OnCloseClick() {
		Debug.Log("CloseClick");
	}

	public void Show() {
		if (gameObject.activeSelf)
			return ;
		gameObject.SetActive(true);
		Module.Control.input3d = false;
		Module.UI.mask.OnClick = Hide;
		Module.UI.mask.Enable(true);
		foreach (var item in Module.Role.bag) {
			int id = item.Value.id;
			int count = item.Value.count;
			createItem(id, count);
		}
		Debug.Log("Bag Show");
	}

	public void Hide() {
		Module.Control.input3d = true;
		Module.UI.mask.OnClick = null;
		Module.UI.mask.Enable(false);
		gameObject.SetActive(false);
		Debug.Log("Bag Hide");
	}

	//////////////////////////////inherit
	void Awake() {
		Module.UI.bag = this;
		Module.UI.mask.Enable(false);
		gameObject.SetActive(false);
	}
}

