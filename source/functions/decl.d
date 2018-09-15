module functions.decl;
import bldso : decompiler;
import opcodes : opcode;

void func_decl(ref decompiler dec) {
	import std.array : insertInPlace;
	string fnName = dec.get_string(dec.fi.code[dec.i++], false);
	string fnNamespace;
	if(dec.fi.code[dec.i] == 0) {
		fnNamespace = "";
	}
	else {
		fnNamespace = dec.get_string(dec.fi.code[dec.i], false);
	}
	dec.i++;
	string fnPackage = dec.get_string(dec.fi.code[dec.i++], false);
	int has_body = dec.fi.code[dec.i++];
	int fnEndIp = dec.fi.code[dec.i++];
	int argc = dec.fi.code[dec.i++];
	string[] argv;
	dec.fi.code.insertInPlace(fnEndIp, opcode.DECOMPILER_ENDFUNC);

	version(Debug) {
		import bldso : dbgPrint;
		import std.conv : to;
		dbgPrint("NEW FUNCTION!");
		string has_body_str = to!string((cast(bool)has_body));
		if(fnNamespace != "") {
			dbgPrint(fnNamespace ~ "::" ~ fnName ~ ", has body: " ~ (cast(bool)has_body ? "true" : "false"));
		}
	}

}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_FUNC_DECL] = &func_decl;
}

