using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Diagnostics;
using zprotobuf;
namespace client_zproto {
public abstract class wirep:wire {
	public override int _serialize(out byte[] dat) {
		return serializer.instance().encode(this, out dat);
	}
	public override int _parse(byte[] dat, int size) {
		return serializer.instance().decode(this, dat, size);
	}
	public override int _tag() {
		return serializer.instance().tag(_name());
	}
}

public class idcount:wirep {
	public int id;
	public int count;

	public override string _name() {
		return "idcount";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, id);
		case 2:
			return write(ref args, count);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out id);
		case 2:
			return read(ref args, out count);
		default:
			return dll.ERROR;
		}
	}
}
public class vector2:wirep {
	public int x;
	public int z;

	public override string _name() {
		return "vector2";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, x);
		case 2:
			return write(ref args, z);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out x);
		case 2:
			return read(ref args, out z);
		default:
			return dll.ERROR;
		}
	}
}
public class a_error:wirep {
	public int cmd;
	public int err;

	public override string _name() {
		return "a_error";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, cmd);
		case 2:
			return write(ref args, err);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out cmd);
		case 2:
			return read(ref args, out err);
		default:
			return dll.ERROR;
		}
	}
}
public class r_accountcreate:wirep {
	public byte[] user;
	public byte[] passwd;

	public override string _name() {
		return "r_accountcreate";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, user);
		case 2:
			return write(ref args, passwd);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out user);
		case 2:
			return read(ref args, out passwd);
		default:
			return dll.ERROR;
		}
	}
}
public class a_accountcreate:wirep {
	public int uid;

	public override string _name() {
		return "a_accountcreate";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, uid);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out uid);
		default:
			return dll.ERROR;
		}
	}
}
public class r_accountchallenge:wirep {

	public override string _name() {
		return "r_accountchallenge";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		default:
			return dll.ERROR;
		}
	}
}
public class a_accountchallenge:wirep {
	public byte[] randomkey;

	public override string _name() {
		return "a_accountchallenge";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, randomkey);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out randomkey);
		default:
			return dll.ERROR;
		}
	}
}
public class r_accountlogin:wirep {
	public int gateid;
	public byte[] user;
	public byte[] passwd;

	public override string _name() {
		return "r_accountlogin";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, gateid);
		case 2:
			return write(ref args, user);
		case 3:
			return write(ref args, passwd);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out gateid);
		case 2:
			return read(ref args, out user);
		case 3:
			return read(ref args, out passwd);
		default:
			return dll.ERROR;
		}
	}
}
public class a_accountlogin:wirep {
	public int uid;
	public int token;

	public override string _name() {
		return "a_accountlogin";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, uid);
		case 2:
			return write(ref args, token);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out uid);
		case 2:
			return read(ref args, out token);
		default:
			return dll.ERROR;
		}
	}
}
public class r_gatelogin:wirep {
	public int uid;
	public int token;

	public override string _name() {
		return "r_gatelogin";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, uid);
		case 2:
			return write(ref args, token);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out uid);
		case 2:
			return read(ref args, out token);
		default:
			return dll.ERROR;
		}
	}
}
public class a_gatelogin:wirep {
	public vector2 coord;

	public override string _name() {
		return "a_gatelogin";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return coord._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			coord = new vector2();
			return coord._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class r_roleinfo:wirep {

	public override string _name() {
		return "r_roleinfo";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		default:
			return dll.ERROR;
		}
	}
}
public class a_roleinfo:wirep {
	public byte[] name;
	public int level;
	public int exp;
	public int gold;
	public idcount[] bag;
	public idcount[] prop;

	public override string _name() {
		return "a_roleinfo";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, name);
		case 2:
			return write(ref args, level);
		case 3:
			return write(ref args, exp);
		case 4:
			return write(ref args, gold);
		case 5:
			if (args.idx >= (int)bag.Length) {
				args.len = args.idx;
				return dll.NOFIELD;
			}
			return bag[args.idx]._encode(args.buff, args.buffsz, args.sttype);
		case 6:
			if (args.idx >= (int)prop.Length) {
				args.len = args.idx;
				return dll.NOFIELD;
			}
			return prop[args.idx]._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out name);
		case 2:
			return read(ref args, out level);
		case 3:
			return read(ref args, out exp);
		case 4:
			return read(ref args, out gold);
		case 5:
			Debug.Assert(args.idx >= 0);
			if (args.idx == 0)
				bag = new idcount[args.len];
			if (args.len == 0)
				return 0;
			bag[args.idx] = new idcount();
			return bag[args.idx]._decode(args.buff, args.buffsz, args.sttype);
		case 6:
			Debug.Assert(args.idx >= 0);
			if (args.idx == 0)
				prop = new idcount[args.len];
			if (args.len == 0)
				return 0;
			prop[args.idx] = new idcount();
			return prop[args.idx]._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class r_rolecreate:wirep {
	public byte[] name;

	public override string _name() {
		return "r_rolecreate";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, name);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out name);
		default:
			return dll.ERROR;
		}
	}
}
public class a_rolecreate:wirep {
	public byte[] name;
	public int level;
	public int exp;
	public int gold;
	public idcount[] bag;
	public idcount[] prop;

	public override string _name() {
		return "a_rolecreate";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, name);
		case 2:
			return write(ref args, level);
		case 3:
			return write(ref args, exp);
		case 4:
			return write(ref args, gold);
		case 5:
			if (args.idx >= (int)bag.Length) {
				args.len = args.idx;
				return dll.NOFIELD;
			}
			return bag[args.idx]._encode(args.buff, args.buffsz, args.sttype);
		case 6:
			if (args.idx >= (int)prop.Length) {
				args.len = args.idx;
				return dll.NOFIELD;
			}
			return prop[args.idx]._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out name);
		case 2:
			return read(ref args, out level);
		case 3:
			return read(ref args, out exp);
		case 4:
			return read(ref args, out gold);
		case 5:
			Debug.Assert(args.idx >= 0);
			if (args.idx == 0)
				bag = new idcount[args.len];
			if (args.len == 0)
				return 0;
			bag[args.idx] = new idcount();
			return bag[args.idx]._decode(args.buff, args.buffsz, args.sttype);
		case 6:
			Debug.Assert(args.idx >= 0);
			if (args.idx == 0)
				prop = new idcount[args.len];
			if (args.len == 0)
				return 0;
			prop[args.idx] = new idcount();
			return prop[args.idx]._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class r_itemuse:wirep {
	public int id;
	public int count;

	public override string _name() {
		return "r_itemuse";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, id);
		case 2:
			return write(ref args, count);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out id);
		case 2:
			return read(ref args, out count);
		default:
			return dll.ERROR;
		}
	}
}
public class a_itemuse:wirep {
	public int hp;

	public override string _name() {
		return "a_itemuse";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return write(ref args, hp);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return read(ref args, out hp);
		default:
			return dll.ERROR;
		}
	}
}
public class r_movedir:wirep {
	public vector2 coord;
	public vector2 dir;

	public override string _name() {
		return "r_movedir";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return coord._encode(args.buff, args.buffsz, args.sttype);
		case 2:
			return dir._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			coord = new vector2();
			return coord._decode(args.buff, args.buffsz, args.sttype);
		case 2:
			dir = new vector2();
			return dir._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class r_movepoint:wirep {
	public vector2 src;
	public vector2 dst;

	public override string _name() {
		return "r_movepoint";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return src._encode(args.buff, args.buffsz, args.sttype);
		case 2:
			return dst._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			src = new vector2();
			return src._decode(args.buff, args.buffsz, args.sttype);
		case 2:
			dst = new vector2();
			return dst._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class r_movestop:wirep {
	public vector2 coord;

	public override string _name() {
		return "r_movestop";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return coord._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			coord = new vector2();
			return coord._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class r_movesync:wirep {
	public vector2 coord;

	public override string _name() {
		return "r_movesync";
	}
	protected override int _encode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			return coord._encode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
	protected override int _decode_field(ref dll.args args)  {
		switch (args.tag) {
		case 1:
			coord = new vector2();
			return coord._decode(args.buff, args.buffsz, args.sttype);
		default:
			return dll.ERROR;
		}
	}
}
public class serializer:wiretree {

	private static serializer inst = null;

	private const string def = "\x69\x64\x63\x6f\x75\x6e\x74\x20\x7b\xa\x9\x2e\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x63\x6f\x75\x6e\x74\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\x76\x65\x63\x74\x6f\x72\x32\x20\x7b\xa\x9\x2e\x78\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x7a\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x63\x6f\x6d\x6d\x6f\x6e\xa\x61\x5f\x65\x72\x72\x6f\x72\x20\x30\x78\x31\x30\x30\x30\x20\x7b\xa\x9\x2e\x63\x6d\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x65\x72\x72\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x61\x63\x63\x6f\x75\x6e\x74\xa\x72\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x72\x65\x61\x74\x65\x20\x30\x78\x32\x30\x30\x30\x20\x7b\xa\x9\x2e\x75\x73\x65\x72\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x9\x2e\x70\x61\x73\x73\x77\x64\x3a\x73\x74\x72\x69\x6e\x67\x20\x32\xa\x7d\xa\xa\x61\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x72\x65\x61\x74\x65\x20\x30\x78\x32\x30\x30\x31\x20\x7b\xa\x9\x2e\x75\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x7d\xa\xa\x72\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x68\x61\x6c\x6c\x65\x6e\x67\x65\x20\x30\x78\x32\x30\x30\x32\x20\x7b\xa\xa\x7d\xa\xa\x61\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x68\x61\x6c\x6c\x65\x6e\x67\x65\x20\x30\x78\x32\x30\x30\x33\x20\x7b\xa\x9\x2e\x72\x61\x6e\x64\x6f\x6d\x6b\x65\x79\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x7d\xa\xa\x72\x5f\x61\x63\x63\x6f\x75\x6e\x74\x6c\x6f\x67\x69\x6e\x20\x30\x78\x32\x30\x30\x34\x20\x7b\xa\x9\x2e\x67\x61\x74\x65\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x75\x73\x65\x72\x3a\x73\x74\x72\x69\x6e\x67\x20\x32\xa\x9\x2e\x70\x61\x73\x73\x77\x64\x3a\x73\x74\x72\x69\x6e\x67\x20\x33\xa\x7d\xa\xa\x61\x5f\x61\x63\x63\x6f\x75\x6e\x74\x6c\x6f\x67\x69\x6e\x20\x30\x78\x32\x30\x30\x35\x20\x7b\xa\x9\x2e\x75\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x74\x6f\x6b\x65\x6e\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\xa\x23\x23\x23\x23\x23\x23\x23\x23\x23\x67\x61\x74\x65\xa\xa\x72\x5f\x67\x61\x74\x65\x6c\x6f\x67\x69\x6e\x20\x30\x78\x32\x30\x66\x30\x20\x7b\xa\x9\x2e\x75\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x74\x6f\x6b\x65\x6e\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\xa\x61\x5f\x67\x61\x74\x65\x6c\x6f\x67\x69\x6e\x20\x30\x78\x32\x30\x66\x31\x20\x7b\xa\x9\x2e\x63\x6f\x6f\x72\x64\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x31\xa\x7d\xa\xa\x23\x23\x23\x23\x23\x23\x23\x23\x72\x6f\x6c\x65\xa\x72\x5f\x72\x6f\x6c\x65\x69\x6e\x66\x6f\x20\x30\x78\x33\x30\x30\x30\x20\x7b\xa\xa\x7d\xa\xa\x61\x5f\x72\x6f\x6c\x65\x69\x6e\x66\x6f\x20\x30\x78\x33\x30\x30\x31\x20\x7b\xa\x9\x2e\x6e\x61\x6d\x65\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x9\x2e\x6c\x65\x76\x65\x6c\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x9\x2e\x65\x78\x70\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x33\xa\x9\x2e\x67\x6f\x6c\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x34\xa\x9\x2e\x62\x61\x67\x3a\x69\x64\x63\x6f\x75\x6e\x74\x5b\x5d\x20\x35\xa\x9\x2e\x70\x72\x6f\x70\x3a\x69\x64\x63\x6f\x75\x6e\x74\x5b\x5d\x20\x36\xa\x7d\xa\xa\x72\x5f\x72\x6f\x6c\x65\x63\x72\x65\x61\x74\x65\x20\x30\x78\x33\x30\x30\x32\x20\x7b\xa\x9\x2e\x6e\x61\x6d\x65\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x7d\xa\xa\x61\x5f\x72\x6f\x6c\x65\x63\x72\x65\x61\x74\x65\x20\x30\x78\x33\x30\x30\x33\x20\x7b\xa\x9\x2e\x6e\x61\x6d\x65\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x9\x2e\x6c\x65\x76\x65\x6c\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x9\x2e\x65\x78\x70\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x33\xa\x9\x2e\x67\x6f\x6c\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x34\xa\x9\x2e\x62\x61\x67\x3a\x69\x64\x63\x6f\x75\x6e\x74\x5b\x5d\x20\x35\xa\x9\x2e\x70\x72\x6f\x70\x3a\x69\x64\x63\x6f\x75\x6e\x74\x5b\x5d\x20\x36\xa\x7d\xa\xa\x72\x5f\x69\x74\x65\x6d\x75\x73\x65\x20\x30\x78\x33\x30\x30\x34\x20\x7b\xa\x9\x2e\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x63\x6f\x75\x6e\x74\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\xa\x61\x5f\x69\x74\x65\x6d\x75\x73\x65\x20\x30\x78\x33\x30\x30\x35\x20\x7b\xa\x9\x2e\x68\x70\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x7d\xa\xa\x23\x23\x23\x23\x23\x23\x23\x23\x73\x63\x65\x6e\x65\xa\x72\x5f\x6d\x6f\x76\x65\x64\x69\x72\x20\x30\x78\x35\x30\x30\x30\x20\x7b\xa\x9\x2e\x63\x6f\x6f\x72\x64\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x31\xa\x9\x2e\x64\x69\x72\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x32\xa\x7d\xa\xa\x72\x5f\x6d\x6f\x76\x65\x70\x6f\x69\x6e\x74\x20\x30\x78\x35\x30\x30\x31\x20\x7b\xa\x9\x2e\x73\x72\x63\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x31\xa\x9\x2e\x64\x73\x74\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x32\xa\x7d\xa\xa\x72\x5f\x6d\x6f\x76\x65\x73\x74\x6f\x70\x20\x30\x78\x35\x30\x30\x32\x20\x7b\xa\x9\x2e\x63\x6f\x6f\x72\x64\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x31\xa\x7d\xa\xa\x23\x75\x73\x65\x64\x20\x62\x79\x20\x67\x61\x74\x65\x2f\x73\x63\x65\x6e\x65\x20\x73\x65\x72\x76\x65\x72\x2c\x20\x6e\x6f\x74\x20\x62\x72\x6f\x61\x64\x63\x61\x73\x74\x20\x63\x6c\x69\x65\x6e\x74\xa\x72\x5f\x6d\x6f\x76\x65\x73\x79\x6e\x63\x20\x30\x78\x35\x30\x30\x33\x20\x7b\xa\x9\x2e\x63\x6f\x6f\x72\x64\x3a\x76\x65\x63\x74\x6f\x72\x32\x20\x31\xa\x7d\xa\xa\xa";
	private serializer():base(def) {

	}

public static serializer instance() {

	if (inst == null)
		inst = new serializer();
	return inst;
}


}
}
