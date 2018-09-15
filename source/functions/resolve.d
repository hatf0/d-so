module functions.resolve;
import bldso : decompiler;
import opcodes : opcode, CallTypes;

void callfunc(ref decompiler dec) {
    int call_type = dec.fi.code[dec.i + 2];
    string fnName = dec.get_string(dec.fi.code[dec.i], false);
    string fnNamespace = "";
    if(dec.fi.code[dec.i + 1] != 0) {
	fnNamespace = dec.get_string(dec.fi.code[dec.i], false);
    }

    string[] argv;
    argv = dec.stacks.a_s[dec.stacks.a_s.length - 1];
    import std.algorithm.mutation : remove;
    dec.stacks.a_s = dec.stacks.a_s.remove(dec.stacks.a_s.length - 1);
    import utilities : constructPrettyFunction;

    dec.stacks.s_s ~= constructPrettyFunction(fnName, fnNamespace, argv, cast(CallTypes)call_type);

    dec.i += 3;

}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_CALLFUNC_RESOLVE] = &callfunc;
	dec.handlers[opcode.OP_CALLFUNC] = &callfunc;
}



