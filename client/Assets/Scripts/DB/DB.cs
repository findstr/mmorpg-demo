using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DB {
public class DB {
	public static Language @Language = new Language();
	public static void Load() {
		@Language.Load();
	}
}}

