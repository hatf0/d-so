module controlstmts.jmps;
import bldso : decompiler;
import opcodes : opcode;
import utilities : popOffStack, addTabulation;
import std.array : insertInPlace;

void if_handler(decompiler dec) {
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
    



}

void jmpifnot_np(decompiler dec) {
    version(Debug) {
	import utilities : addTabulation;
	dec.fi.outputFile.writeln(addTabulation("//JMPIFNOT_NP"));
    }

    dec.stacks.b_s ~= popOffStack(dec.stacks.i_s) ~ " && ";

    int jmp_target = dec.fi.code[dec.i] - dec.offset;

    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_END_BINOP);
    dec.i++;
}

void jmpif(decompiler dec) {
    dec.i++;
}

void jmpiff(decompiler dec) {
    assert(0, "unfinished");
}

void jmpif_np(decompiler dec) {
    version(Debug) {
	import utilities : addTabulation;
	dec.fi.outputFile.writeln(addTabulation("//JMPIF_NP"));
    }

    dec.stacks.b_s ~= popOffStack(dec.stacks.i_s) ~ " || ";

    int jmp_target = dec.fi.code[dec.i] - dec.offset;

    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_END_BINOP);
    dec.i++;

}

void jmp(decompiler dec) {
    int jmp_target = dec.fi.code[dec.i] - dec.offset;
    dec.fi.code.insertInPlace(jmp_target, opcode.DECOMPILER_ENDWHILE);
    dec.i++;

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_JMPIFNOT] = &if_handler;
	dec.handlers[opcode.OP_JMPIFFNOT] = &if_handler;
	dec.handlers[opcode.OP_JMPIFNOT_NP] = &jmpifnot_np;
	dec.handlers[opcode.OP_JMPIF] = &jmpif;
	dec.handlers[opcode.OP_JMPIFF] = &jmpiff;
	dec.handlers[opcode.OP_JMPIF_NP] = &jmpif_np;
	dec.handlers[opcode.OP_JMP] = &jmp;
}
