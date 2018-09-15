module typeconvs.t_float;
import opcodes : opcode;
import bldso : decompiler;
import utilities : popOffStack;

void flt_to_str(ref decompiler dec) {
	dec.stacks.s_s ~= popOffStack(dec.stacks.f_s);
}

void flt_to_uint(ref decompiler dec) {
	dec.stacks.i_s ~= popOffStack(dec.stacks.f_s);
}

void flt_to_none(ref decompiler dec) {
	popOffStack(dec.stacks.f_s);
}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_FLT_TO_NONE] = &flt_to_none;
	dec.handlers[opcode.OP_FLT_TO_UINT] = &flt_to_uint;
	dec.handlers[opcode.OP_FLT_TO_STR] = &flt_to_str;
}



