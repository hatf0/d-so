module special.dechandlers;
import bldso : decompiler;
import opcodes : opcode;
import std.algorithm;
import std.array;
import utilities : popOffStack;

void endfunc(decompiler dec) {

}

void endif(decompiler dec) {

}

void endwhile(decompiler dec) {

}

void _else(decompiler dec) {

}

void endwhile_float(decompiler dec) {

}

void endif_shortjmp(decompiler dec) {

}

void end_binop(decompiler dec) {
    if(dec.fi.code[dec.i - 1] == opcode.DECOMPILER_END_BINOP) {
	dec.fi.code = dec.fi.code.remove(dec.i - 1);
    }
    dec.i--;
    string lhs = popOffStack(dec.stacks.b_s);
    string rhs = "";
    if(dec.stacks.i_s.length > 0) {
	rhs = popOffStack(dec.stacks.i_s);
    }
    else if(dec.stacks.f_s.length > 0) {
	rhs = popOffStack(dec.stacks.f_s);
    }
    else if(dec.stacks.s_s.length > 0) {
	rhs = popOffStack(dec.stacks.s_s);
    }

    if(rhs.canFind("&&") || rhs.canFind("||")) {
	rhs = "(" ~ rhs ~ ")";
    }
    dec.stacks.i_s ~= lhs ~ rhs;
}


void bootup(decompiler dec) {
    dec.handlers[opcode.DECOMPILER_ENDFUNC] = &endfunc;
    dec.handlers[opcode.DECOMPILER_ENDIF] = &endif;
    dec.handlers[opcode.DECOMPILER_ENDWHILE] = &endwhile;
    dec.handlers[opcode.DECOMPILER_ELSE] = &_else;
    dec.handlers[opcode.DECOMPILER_ENDWHILE_FLOAT] = &endwhile_float;
    dec.handlers[opcode.DECOMPILER_ENDIF_SHORTJMP] = &endif_shortjmp;
    dec.handlers[opcode.DECOMPILER_END_BINOP] = &end_binop;

}

