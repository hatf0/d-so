module variables.loadvar;
import bldso : decompiler;
import opcodes : opcode;

void loadimmed_uint(decompiler dec) {

}

void loadimmed_str(decompiler dec) {

}

void loadimmed_flt(decompiler dec) {

}

void loadimmed_ident(decompiler dec) {

}

void loadvar_uint(decompiler dec) {

}

void loadvar_str(decompiler dec) {

}

void loadvar_flt(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_LOADVAR_FLT] = &loadvar_flt;
	dec.handlers[opcode.OP_LOADVAR_STR] = &loadvar_str;
	dec.handlers[opcode.OP_LOADVAR_UINT] = &loadvar_uint;
	dec.handlers[opcode.OP_LOADIMMED_IDENT] = &loadimmed_ident;
	dec.handlers[opcode.OP_LOADIMMED_STR] = &loadimmed_str;
	dec.handlers[opcode.OP_LOADIMMED_UINT] = &loadimmed_uint;
	dec.handlers[opcode.OP_LOADIMMED_FLT] = &loadimmed_flt;
}



