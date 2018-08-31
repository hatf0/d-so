module maths.binops;
import bldso : decompiler;
import opcodes : opcode;
import utilities : popOffStack;

void bin_or(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " | " ~ popOffStack(dec.stacks.i_s);
}

void bin_bitor(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " | " ~ popOffStack(dec.stacks.i_s);
}

void bin_not(decompiler dec) {
    string op = popOffStack(dec.stacks.i_s);
    import std.algorithm.searching : canFind; 
    import std.string : replace;
    if(op.canFind("==")) {
	op = op.replace("==", "!=");
    }
    else if(op.canFind("!=")) {
	op = op.replace("!=", "==");
    }
    else if(op.canFind("$=")) {
	op = op.replace("$=", "!$=");
    }
    else if(op.canFind("!$=")) {
	op = op.replace("!$=", "$=");
    }
    else if(!op.canFind("!")) {
	op = "!" ~ op;
    }
    else if(op.canFind(" ")) {
	op = "!(" ~ op ~ ")";
    }
    else {
	op = op[1..op.length - 1];
    }
    dec.stacks.i_s ~= op;
}

void bin_xor(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " ^ " ~ popOffStack(dec.stacks.i_s);
}

void bin_and(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " & " ~ popOffStack(dec.stacks.i_s);
}

void bin_bitand(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " & " ~ popOffStack(dec.stacks.i_s);
}

void bin_shl(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " << " ~ popOffStack(dec.stacks.i_s);
}

void bin_shr(decompiler dec) {
    dec.stacks.i_s ~= popOffStack(dec.stacks.i_s) ~ " >> " ~ popOffStack(dec.stacks.i_s);
}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_SHL] = &bin_shl;
	dec.handlers[opcode.OP_SHR] = &bin_shr;
	dec.handlers[opcode.OP_OR] = &bin_or;
	dec.handlers[opcode.OP_BITOR] = &bin_bitor;
	dec.handlers[opcode.OP_XOR] = &bin_xor;
	dec.handlers[opcode.OP_AND] = &bin_and;
	dec.handlers[opcode.OP_BITAND] = &bin_bitand;
	dec.handlers[opcode.OP_NOT] = &bin_not;
	dec.handlers[opcode.OP_NOTF] = &bin_not;
}




