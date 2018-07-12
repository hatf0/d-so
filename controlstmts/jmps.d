module controlstmts.jmps;
import bldso : decompiler;
import opcodes : opcode;

void jmpifnot(decompiler dec) {

}

void jmpiffnot(decompiler dec) {

}

void jmpifnot_np(decompiler dec) {

}

void jmpif(decompiler dec) {

}

void jmpiff(decompiler dec) {

}

void jmpif_np(decompiler dec) {

}

void jmp(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_JMPIFNOT] = &jmpifnot;
	dec.handlers[opcode.OP_JMPIFFNOT] = &jmpiffnot;
	dec.handlers[opcode.OP_JMPIFNOT_NP] = &jmpifnot_np;
	dec.handlers[opcode.OP_JMPIF] = &jmpif;
	dec.handlers[opcode.OP_JMPIFF] = &jmpiff;
	dec.handlers[opcode.OP_JMPIF_NP] = &jmpif_np;
	dec.handlers[opcode.OP_JMP] = &jmp;
}
