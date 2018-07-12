module variables.savevar;
import bldso : decompiler;
import opcodes : opcode;

void savevar_uint(decompiler dec) {

}

void savevar_str(decompiler dec) {

}

void savevar_flt(decompiler dec) {

}

void setcurvar(decompiler dec) {

}

void setcurvar_create(decompiler dec) {

}


void bootup(decompiler dec) {
	dec.handlers[opcode.OP_SAVEVAR_FLT] = &savevar_flt;
	dec.handlers[opcode.OP_SAVEVAR_STR] = &savevar_str;
	dec.handlers[opcode.OP_SAVEVAR_UINT] = &savevar_uint;
	dec.handlers[opcode.OP_SETCURVAR] = &setcurvar;
	dec.handlers[opcode.OP_SETCURVAR_CREATE] = &setcurvar_create;
}



