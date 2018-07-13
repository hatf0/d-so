module maths.cmps;
import bldso : decompiler;
import opcodes;
import utilities : getComparison, popOffStack;

void cmphandler(decompiler dec) {
	string lhs = popOffStack(dec.stacks.f_s);
	string rhs = popOffStack(dec.stacks.f_s);
	dec.stacks.f_s ~= lhs ~ " " ~ getComparison(dec.status.currentOpcode) ~ " " ~ rhs;
}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_CMPEQ] = &cmphandler;
	dec.handlers[opcode.OP_CMPGR] = &cmphandler;
	dec.handlers[opcode.OP_CMPLE] = &cmphandler;
	dec.handlers[opcode.OP_CMPNE] = &cmphandler;
	dec.handlers[opcode.OP_CMPLT] = &cmphandler;
	dec.handlers[opcode.OP_CMPGE] = &cmphandler;
}

