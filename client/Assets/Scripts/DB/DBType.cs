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
	public string Value;
}

public class ItemUseItem {
	public int Key;
	public IdCount[] Prop;
}

}

