using System;
using System.Xml;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DB {

public abstract class XmlLoad {
	public abstract void Load(string path);
}

public class XmlSet<T, K> : XmlLoad where T:new(){
	private Dictionary<K, T> pool = new Dictionary<K, T>();
	public T Get(K key) {
		if (pool.ContainsKey(key))
			return pool[key];
		return default(T);
	}
	private char[] delim = {','};
	private char[] idcount= {':'};
	private void Parse(ref IdCount o, string str) {
		string[] a = str.Split(idcount);
		Debug.Log("ParseIdCount:" + str + a.Length);
		Debug.Assert(a.Length == 2);
		o.id = int.Parse(a[0]);
		o.count = int.Parse(a[1]);
	}
	private void Parse(ref int o, string str) {
		o = int.Parse(str);
	}
	public override void Load(string path) {
		XmlDocument doc = new XmlDocument();
		var text = (TextAsset)Resources.Load(path);
		//Debug.Log("XmlLoad:" + path);
		doc.LoadXml(text.text);
		XmlNode root = doc.DocumentElement;
		for (int i = 0; i < root.ChildNodes.Count; i++) {
			var n = root.ChildNodes[i];
			T var = new T();
			FieldInfo[] fi = var.GetType().GetFields();
			for (int j = 0; j < fi.Length; j++) {
				var val = n.Attributes.GetNamedItem(fi[j].Name).Value;
				if (val == "")
					continue;
				if (fi[j].FieldType.IsArray) {
					string[] words = val.Split(delim);
					if (fi[j].FieldType == typeof(IdCount[])) {
						IdCount[] l = new IdCount[words.Length];
						for (int k = 0; k < words.Length; k++)
							Parse(ref l[k], words[k]);
						fi[j].SetValue(var, l);
					} else if (fi[j].FieldType == typeof(int[])) {
						int[] l = new int[words.Length];
						for (int k = 0; k < words.Length; k++)
							Parse(ref l[k], words[k]);
						fi[j].SetValue(var, l);
					} else {
						Debug.Assert(false);
					}
				} else {
					fi[j].SetValue(var, Convert.ChangeType(val, fi[j].FieldType));
				}
				if (fi[j].Name == "Key")
					pool[(K)fi[j].GetValue(var)] = var;
			}
		}
	}
}


public class DB {
	public static XmlSet<LanguageItem, string> LanguageCN = new XmlSet<LanguageItem, string>();
	public static XmlSet<RoleLevelItem, int> RoleLevel = new XmlSet<RoleLevelItem, int>();
	public static XmlSet<ItemItem, int> Item = new XmlSet<ItemItem, int>();
	public static XmlSet<ErrnoItem, int> Errno = new XmlSet<ErrnoItem, int>();
	public static XmlSet<IPConfigItem, string> IpConfig = new XmlSet<IPConfigItem, string>();

	private static bool loaded = false;
	public static void Load() {
		if (loaded)
			return ;
		loaded = true;
		FieldInfo[] fi = typeof(DB).GetFields();
		Debug.Log("Load:"+  fi.Length);
		for (int j = 0; j < fi.Length; j++) {
			var name = fi[j].Name;
			XmlLoad obj = (XmlLoad)fi[j].GetValue(null);
			obj.Load("DB/" + name);
		}
	}
}}

