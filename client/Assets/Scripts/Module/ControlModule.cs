using System.Collections.Generic;
using UnityEngine;
namespace Module {
public class Control {
	private static int clock_delta;
	public static bool input3d = true;
	public static uint clock {
		set { clock_delta = (int)(value - (uint)(Time.time * 1000)); }
		get { return (uint)((Time.time * 1000) + clock_delta); }
	}
}
}

