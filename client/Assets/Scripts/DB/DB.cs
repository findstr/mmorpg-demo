using System;
using System.Xml;
using System.IO;
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
	private IdCount ParseIdCount(string str) {
		Debug.Log("IdCount");
		return default(IdCount);
	}
	private int ParseInt(string str) {
		Debug.Log("Int");
		return default(int);
	}
	public override void Load(string path) {
		XmlDocument doc = new XmlDocument();
		if (!System.IO.File.Exists(path))
			return ;
		doc.LoadXml(System.IO.File.ReadAllText(path));
		XmlNode root = doc.DocumentElement;
		for (int i = 0; i < root.ChildNodes.Count; i++) {
			var n = root.ChildNodes[i];
			T var = new T();
			FieldInfo[] fi = var.GetType().GetFields();
			for (int j = 0; j < fi.Length; j++) {
				var val = n.Attributes.GetNamedItem(fi[j].Name).Value;
				if (fi[j].FieldType.IsArray) {
					string[] words = val.Split(delim);
					Array a = Array.CreateInstance(fi[i].FieldType.GetElementType(), words.Length);
					for (int k = 0; k < words.Length; k++) {
						a.SetValue(
						Parse(ref (fi[i].FieldType.GetElementType())(a[k]), words[k]);
						Debug.Log("Parse:" + words[k]);
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
	public static XmlSet<LanguageItem, string> Language = new XmlSet<LanguageItem, string>();
	public static XmlSet<RoleLevelItem, int> RoleLevel = new XmlSet<RoleLevelItem, int>();

	public static void Load() {
		FieldInfo[] fi = typeof(DB).GetFields();
		Debug.Log("Load:"+  fi.Length);
		for (int j = 0; j < fi.Length; j++) {
			var name = fi[j].Name;
			XmlLoad obj = (XmlLoad)fi[j].GetValue(null);
			obj.Load(Tool.GetPath("DB/" + name + ".xml"));
		}
		Debug.Log("RoleLevel:" + RoleLevel.Get(1).Value);
	}
}}

