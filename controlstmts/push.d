module controlstmts.push;
import bldso : decompiler;
import opcodes : opcode;

void push(decompiler dec) {

}

void push_frame(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_PUSH] = &push;
	dec.handlers[opcode.OP_PUSH_FRAME] = &push_frame;

}

