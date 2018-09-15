module maths.ops;
import bldso : decompiler;
import opcodes : opcode;
import utilities : popOffStack;

void genericMathOp(ref decompiler dec) {
	import std.algorithm : canFind;
	string rhs = popOffStack(dec.stacks.f_s), lhs = popOffStack(dec.stacks.f_s);
	string op = "";
	switch(dec.status.currentOpcode) {
		case opcode.OP_ADD:
			op = " + ";
			break;
		case opcode.OP_SUB:
			op = " - ";
			break;
		case opcode.OP_MUL:
			op = " * ";
			break;
		case opcode.OP_DIV:
			op = " / ";
			break;
		case opcode.OP_MOD:
			op = " % ";
			break;
		default:
			break;
	}

	if(dec.status.currentOpcode == opcode.OP_MUL || dec.status.currentOpcode == opcode.OP_DIV) {
		if(lhs.canFind("+") || lhs.canFind("-")) {
			lhs = "(" ~ lhs ~ ")";
		}
		if(rhs.canFind("+") || lhs.canFind("-")) {
			rhs = "(" ~ rhs ~ ")";
		}
	}

	dec.stacks.f_s ~= lhs ~ op ~ rhs;
}

void neg(ref decompiler dec) {
	string target = popOffStack(dec.stacks.f_s);
	if(target[0] == '-') {
		dec.stacks.f_s ~= target[1..target.length];
	}
	else {
		dec.stacks.f_s ~= "-" ~ target;
	}
}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_ADD] = &genericMathOp;
	dec.handlers[opcode.OP_SUB] = &genericMathOp;
	dec.handlers[opcode.OP_MUL] = &genericMathOp;
	dec.handlers[opcode.OP_DIV] = &genericMathOp;
	dec.handlers[opcode.OP_MOD] = &genericMathOp;
	dec.handlers[opcode.OP_NEG] = &neg;
}




