namespace DB {

public struct IdCount {
	public int id;
	public int count;
}

public class LanguageItem {
	public string Key;
	public string Value;
}

public class RoleLevelItem {
	public int Key;
	public int Exp;
	public int Mp;
	public int Hp;
	public int Atk;
	public int Def;
	public int Matk;
	public int Mdef;
	public int Task;
}

public class ItemUseItem {
	public int Key;
	public IdCount[] Prop;
}

public class ItemItem {
	public int Key;
	public string Desc;
	public string Icon;
}

public class ErrnoItem {
	public int Key;
	public string Value;
}

public class IPConfigItem {
	public string Key;
	public string IP;
	public int Port;
}

public class NPCItem {
	public int Key;
	public int type;
	public int distance;
	public string name;
	public string model;
}
}
