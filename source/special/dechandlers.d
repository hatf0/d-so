module special.dechandlers;
import bldso : decompiler;
import opcodes : opcode;
import std.algorithm;
import std.array;
import utilities : popOffStack;

void endfunc(ref decompiler dec) {
	version(Debug) {
		dec.step_by_step = false;
	}
	
	dec.fi.code = dec.fi.code.remove(dec.i - 1);
	dec.indentation = 0;
	dec.writeln("}\n");
	dec.status.enteredFunction = false;
	dec.i--;
}

void end_generic(ref decompiler dec) {
	dec.indentation--;
	dec.writeln("}");
	if(dec.status.currentOpcode == opcode.DECOMPILER_ENDWHILE) {
		if(dec.stacks.i_s.length > 0) {
			popOffStack(dec.stacks.i_s);
		}
		dec.i++;
	}
	else if(dec.status.currentOpcode == opcode.DECOMPILER_ENDWHILE_FLOAT) {
		if(dec.stacks.f_s.length > 0) {
			popOffStack(dec.stacks.f_s);
		}
		dec.i++;
	}
	else {
		dec.fi.code = dec.fi.code.remove(dec.i - 1);
		dec.i--;
	}

}

void _else(ref decompiler dec) {
	dec.indentation--;
	dec.writeln("}");
	dec.writeln("else {");
	dec.indentation++;
	dec.i++;
}

void end_binop(ref decompiler dec) {
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


void bootup(ref decompiler dec) {
    dec.handlers[opcode.DECOMPILER_ENDFUNC] = &endfunc;
    dec.handlers[opcode.DECOMPILER_ENDIF] = &end_generic;
    dec.handlers[opcode.DECOMPILER_ENDWHILE] = &end_generic;
    dec.handlers[opcode.DECOMPILER_ELSE] = &_else;
    dec.handlers[opcode.DECOMPILER_ENDWHILE_FLOAT] = &end_generic;
    dec.handlers[opcode.DECOMPILER_ENDIF_SHORTJMP] = &end_generic;
//    dec.handlers[opcode.DECOMPILER_END_BINOP] = &end_binop;
}

