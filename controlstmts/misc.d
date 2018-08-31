module controlstmts.misc;
import bldso : decompiler;
import opcodes : opcode;

void ts_return(decompiler dec) {
	import utilities : addTabulation, popOffStack;
	if(!dec.status.enteredFunction || !dec.status.enteredObjCreation) {
		return;
	}
	string final_val = addTabulation("return", dec.indentation);
	string return_value = "(NULL)";
	if(dec.stacks.s_s.length != 0) {
		return_value = popOffStack(dec.stacks.s_s);
		final_val ~= " " ~ return_value ~ ";";
	}
	else { 
		final_val ~= ";";
	}

	version(Debug) {
		opcodes[] lookback = cast(opcodes)dec.stacks.l_s;
		dec.fi.outputFile.writeln(to!string(lookback));
	}

	if(return_value != "(NULL)") {
		dec.fi.outputFile.writeln(final_val);
	}
	else if(dec.i != dec.fi.code.length && dec.fi.code[dec.i] != opcode.DECOMPILER_ENDFUNC && dec.i + 1 != dec.fi.code.length && dec.stacks.l_s[2] != opcode.DECOMPILER_ENDFUNC) {
		dec.fi.outputFile.writeln(final_val);
	}
	else { 
		version(Debug) {
			dec.fi.outputFile.writeln("//IGNORED RETURN");
		}
	}


}

void ts_break(decompiler dec) { 
	import bldso : dbgPrint;
	dbgPrint("Encountered a break operation");
}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_RETURN] = &ts_return;
	dec.handlers[opcode.OP_BREAK] = &ts_break;
}


