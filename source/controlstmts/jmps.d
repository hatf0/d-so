module controlstmts.jmps;
import bldso : decompiler;
import opcodes : opcode;
import utilities : popOffStack, addTabulation;
import std.array : insertInPlace;

void if_handler(ref decompiler dec) {
    int jmp_target = dec.fi.code[dec.i] - dec.offset;
    if(jmp_target < ((dec.i - 1) - dec.offset)) {
	assert(0, "backwards jump encountered");
    }

    version(Debug) {
	dec.fi.outputFile.writeln("//", dec.i, " ", jmp_target, " ", dec.offset);
    }

    if(jmp_target == dec.i + 1) {
	//short jump, eliminate
	import std.conv : to;
	version(Debug) dec.fi.outputFile.writeln("//", to!string(cast(opcode)dec.fi.code[jmp_target])); 
	if(dec.fi.code[jmp_target] == opcode.OP_RETURN) {
	    if(dec.status.currentOpcode == opcode.OP_JMPIFNOT) {
	    	dec.writeln("if (" ~ popOffStack(dec.stacks.i_s) ~ ") {");
	    }
	    else {
		dec.writeln("if (" ~ popOffStack(dec.stacks.f_s) ~ ") {");
	    }
	    dec.writeln("\treturn;");
	    dec.writeln("}");
	    dec.i = jmp_target + 1;
	    return;
	}

	//Okay, it's possibly empty, or it might have a one-liner. We don't know.

	dec.i++;

	if(dec.status.currentOpcode == opcode.OP_JMPIFNOT) {
	    popOffStack(dec.stacks.i_s);
	}
        else {
	    popOffStack(dec.stacks.f_s);
	}

	return;
    }
    
    int op_before_dest = dec.fi.code[jmp_target - 2];
    int op_before_jmp = dec.fi.code[jmp_target - 4];
    
    version(Debug) {
	if(dec.step_by_step) {
	    curFile.writeln("//OP_BEFORE_DEST ", to!string(cast(opcodes)op_before_dest));
	    curFile.writeln("//POS OF OP_BEFORE_DEST: ", jmp_target - 2);
	    curFile.writeln("//OP_BEFORE_JMP ", to!string(cast(opcodes)op_before_jmp));
	    curFile.writeln("//POS OF OP_BEFORE_JMP: ", jmp_target - 4);
	}
    }

    if(jmp_target - 4 == dec.i) {
	//DECOMPILER_SHORT_JMP
	version(Debug) {
	    dec.writeln("//VERY SHORT JUMP");
	}
	if(dec.status.currentOpcode == opcode.OP_JMPIFNOT) {
	    dec.writeln("if (" ~ popOffStack(dec.stacks.i_s) ~ ") {");
	}
    	else {
	    dec.writeln("if (" ~ popOffStack(dec.stacks.f_s) ~ ") {");
	}
	dec.indentation++;
	dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_ENDIF);
	if(dec.fi.code[jmp_target + 1] == opcode.OP_JMPIFNOT) {
	    op_before_dest = dec.fi.code[jmp_target - 1];
	    dec.fi.code[jmp_target - 2] = opcode.DECOMPILER_ELSE;
	    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_ENDIF_SHORTJMP);
	}
	dec.i++;
	return;

    }
    if(op_before_dest == opcode.OP_JMP) {
	//Partial decompile/ternary shit here. I don't want to deal with that.
    }
    else if(op_before_dest == opcode.OP_JMPIFNOT || op_before_dest == opcode.OP_JMPIF) {
	dec.writeln("while (" ~ popOffStack(dec.stacks.i_s) ~ ") {");
	dec.indentation++;
	dec.fi.code[jmp_target - 2] = opcode.DECOMPILER_ENDWHILE;
    }
    else if(op_before_dest == opcode.OP_JMPIFF || op_before_dest == opcode.OP_JMPIFFNOT) {
	dec.writeln("while (" ~ popOffStack(dec.stacks.i_s) ~ ") {");
	dec.indentation++;
	dec.fi.code[jmp_target - 2] = opcode.DECOMPILER_ENDWHILE;
    }
    else {
	if(dec.status.currentOpcode == opcode.OP_JMPIFNOT) {
	    dec.writeln("if (" ~ popOffStack(dec.stacks.i_s) ~ ") {");
	}
    	else {
	    dec.writeln("if (" ~ popOffStack(dec.stacks.f_s) ~ ") {");
	}
	dec.indentation++;
	dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_ENDIF);
    }
    dec.i++;
    return;
}

void jmpifnot_np(ref decompiler dec) {
    version(Debug) {
	import utilities : addTabulation;
	dec.fi.outputFile.writeln(addTabulation("//JMPIFNOT_NP"));
    }

    dec.stacks.b_s ~= popOffStack(dec.stacks.i_s) ~ " && ";

    int jmp_target = dec.fi.code[dec.i] - dec.offset;

    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_END_BINOP);
    dec.i++;
}

void jmpif(ref decompiler dec) {
    dec.i++;
}

void jmpiff(ref decompiler dec) {
    assert(0, "unfinished");
}

void jmpif_np(ref decompiler dec) {
    version(Debug) {
	import utilities : addTabulation;
	dec.fi.outputFile.writeln(addTabulation("//JMPIF_NP"));
    }

    dec.stacks.b_s ~= popOffStack(dec.stacks.i_s) ~ " || ";

    int jmp_target = dec.fi.code[dec.i] - dec.offset;

    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_END_BINOP);
    dec.i++;

}

void jmp(ref decompiler dec) {
    int jmp_target = dec.fi.code[dec.i] - dec.offset;
    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_ENDWHILE);
    dec.i++;

}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_JMPIFNOT] = &if_handler;
	dec.handlers[opcode.OP_JMPIFFNOT] = &if_handler;
	dec.handlers[opcode.OP_JMPIFNOT_NP] = &jmpifnot_np;
	dec.handlers[opcode.OP_JMPIF] = &jmpif;
	dec.handlers[opcode.OP_JMPIFF] = &jmpiff;
	dec.handlers[opcode.OP_JMPIF_NP] = &jmpif_np;
	dec.handlers[opcode.OP_JMP] = &jmp;
}
