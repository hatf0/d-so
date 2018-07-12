module typeconvs.t_float;
import opcodes : opcode;
import bldso : decompiler;

void flt_to_str(decompiler dec) {

}

void flt_to_uint(decompiler dec) {

}

static void flt_to_none(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[cast(int)opcode.OP_FLT_TO_NONE] = &flt_to_none;
	dec.handlers[opcode.OP_FLT_TO_UINT] = &flt_to_uint;
	dec.handlers[opcode.OP_FLT_TO_STR] = &flt_to_str;
}



