module controlstmts.push;
import bldso : decompiler;
import opcodes : opcode;

void push(ref decompiler dec) {
	import utilities : popOffStack;
	// Pop a string off of the string stack, and stick it in the last 
	dec.stacks.a_s[dec.stacks.a_s.length - 1] ~= [popOffStack(dec.stacks.s_s)];


}

void push_frame(ref decompiler dec) {
	dec.stacks.a_s ~= [[]];
	//Add a new arguments frame to the arguments stack.
}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_PUSH] = &push;
	dec.handlers[opcode.OP_PUSH_FRAME] = &push_frame;
}

