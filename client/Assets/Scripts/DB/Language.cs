using System;
using System.IO;
using System.Xml;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace DB {
public class LanguageItem {
	public string Key;
	public string Value;
};
public class Language {
	private Dictionary<string, LanguageItem> pool;

	public void Get(string key) {

	}

	public void Load() {
		XmlDocument doc = new XmlDocument();
		var path = Tool.GetPath("DB/LanguageCN.xml");
		if (!System.IO.File.Exists(path))
			return ;
		Debug.Log("!!!Load:");
		doc.LoadXml(System.IO.File.ReadAllText(path));
		XmlNode root = doc.DocumentElement;
		for (int i = 0; i < root.ChildNodes.Count; i++) {
			var n = root.ChildNodes[i];
			LanguageItem var = new LanguageItem();
			FieldInfo[] fi = var.GetType().GetFields();
			Debug.Log("Reflection:" + fi.Length);
			for (int j = 0; j < fi.Length; j++) {
				fi[j].SetValue(var, n.Attributes.GetNamedItem(fi[j].Name).Value);
				Debug.Log("XX:" + fi[j].Name + ":" + fi[j].MemberType);
				Debug.Log("xml:" + n.Attributes.GetNamedItem(fi[j].Name).Value);
			}
			Debug.Log("xmlRes:" + var.Key + ":" + var.Value);
		}
	}
}}
