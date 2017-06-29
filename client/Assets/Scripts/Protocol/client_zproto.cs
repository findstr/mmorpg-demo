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
public class serializer:wiretree {

	private static serializer inst = null;

	private const string def = "\x61\x5f\x65\x72\x72\x6f\x72\x20\x30\x78\x31\x30\x30\x30\x20\x7b\xa\x9\x2e\x63\x6d\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x65\x72\x72\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x23\x61\x63\x63\x6f\x75\x6e\x74\xa\x72\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x72\x65\x61\x74\x65\x20\x30\x78\x32\x30\x30\x30\x20\x7b\xa\x9\x2e\x75\x73\x65\x72\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x9\x2e\x70\x61\x73\x73\x77\x64\x3a\x73\x74\x72\x69\x6e\x67\x20\x32\xa\x7d\xa\xa\x61\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x72\x65\x61\x74\x65\x20\x30\x78\x32\x30\x30\x31\x20\x7b\xa\x9\x2e\x75\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x7d\xa\xa\x72\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x68\x61\x6c\x6c\x65\x6e\x67\x65\x20\x30\x78\x32\x30\x30\x32\x20\x7b\xa\xa\x7d\xa\xa\x61\x5f\x61\x63\x63\x6f\x75\x6e\x74\x63\x68\x61\x6c\x6c\x65\x6e\x67\x65\x20\x30\x78\x32\x30\x30\x33\x20\x7b\xa\x9\x2e\x72\x61\x6e\x64\x6f\x6d\x6b\x65\x79\x3a\x73\x74\x72\x69\x6e\x67\x20\x31\xa\x7d\xa\xa\x72\x5f\x61\x63\x63\x6f\x75\x6e\x74\x6c\x6f\x67\x69\x6e\x20\x30\x78\x32\x30\x30\x34\x20\x7b\xa\x9\x2e\x67\x61\x74\x65\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x75\x73\x65\x72\x3a\x73\x74\x72\x69\x6e\x67\x20\x32\xa\x9\x2e\x70\x61\x73\x73\x77\x64\x3a\x73\x74\x72\x69\x6e\x67\x20\x33\xa\x7d\xa\xa\x61\x5f\x61\x63\x63\x6f\x75\x6e\x74\x6c\x6f\x67\x69\x6e\x20\x30\x78\x32\x30\x30\x35\x20\x7b\xa\x9\x2e\x75\x69\x64\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x31\xa\x9\x2e\x74\x6f\x6b\x65\x6e\x3a\x69\x6e\x74\x65\x67\x65\x72\x20\x32\xa\x7d\xa\xa\xa\x23\x23\x23\x23\x23\x23\x23\x23\x72\x6f\x6c\x65\xa\xa\xa";
	private serializer():base(def) {

	}

public static serializer instance() {

	if (inst == null)
		inst = new serializer();
	return inst;
}


}
}
