module maths.ops;
import bldso : decompiler;
import opcodes : opcode;

void add(decompiler dec) { 

}

void sub(decompiler dec) {

}

void mod(decompiler dec) {

}

void mul(decompiler dec) {

}

void div(decompiler dec) {

}

void neg(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_ADD] = &add;
	dec.handlers[opcode.OP_SUB] = &sub;
	dec.handlers[opcode.OP_MUL] = &mul;
	dec.handlers[opcode.OP_DIV] = &div;
	dec.handlers[opcode.OP_MOD] = &mod;
	dec.handlers[opcode.OP_NEG] = &neg;
}




