module variables.arrays;
import bldso : decompiler;
import opcodes : opcode;

void setcurvar_array(decompiler dec) {

}

void setcurvar_array_create(decompiler dec) {

}

void setcurfield_array(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_SETCURFIELD_ARRAY] = &setcurfield_array;
	dec.handlers[opcode.OP_SETCURVAR_ARRAY_CREATE] = &setcurvar_array_create;
	dec.handlers[opcode.OP_SETCURVAR_ARRAY] = &setcurvar_array;
}

