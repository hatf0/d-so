module variables.loadvar;
import bldso : decompiler;
import opcodes : opcode;

void loadimmed_uint(decompiler dec) {
	import std.conv : to;
	dec.stacks.i_s ~= to!string(dec.fi.code[dec.i]);
	dec.i++;
}

void loadimmed_str(decompiler dec) {
	import std.string : replace, isNumeric;
	import std.algorithm : canFind;
	string fix_up = dec.get_string(dec.fi.code[dec.i], dec.status.enteredFunction);

	/* 
	   Replace all of the control characters with the escaped version
	*/

	if(fix_up.canFind('\n')) {
		fix_up = fix_up.replace('\n', "\\n");
	}

	if(fix_up.canFind('\r')) { 
		fix_up = fix_up.replace('\r', "\\r");
	}

	if (fix_up.canFind('\t')) {
		fix_up = fix_up.replace('\t', "\\t");
	}

	/* 
	   Color codes 
	   Thanks to Electrk for figuring this out!!
	   \c0 -> \cf
	   \c1 -> \c2
	   \c2 -> \c3
	   \c3 -> \c4
	   \c4 -> \c5
	   \c5 -> \c6
	   \c6 -> \c7
	   \c7 -> \cb
	   \c8 -> \cc
	   \c9 -> \ce
	 */

	if (fix_up.canFind('\x0f')) {
		fix_up = fix_up.replace('\x0f', "\\c0");
	}

	if (fix_up.canFind('\x02')) {
		fix_up = fix_up.replace('\x02', "\\c1");
	}

	if (fix_up.canFind('\x03')) {
		fix_up = fix_up.replace('\x03', "\\c2");
	}
	
	if (fix_up.canFind('\x04')) {
		fix_up = fix_up.replace('\x04', "\\c3");
	}

	if (fix_up.canFind('\x05')) {
		fix_up = fix_up.replace('\x05', "\\c4");
	}

	if (fix_up.canFind('\x06')) {
		fix_up = fix_up.replace('\x06', "\\c5");
	}

	if (fix_up.canFind('\x07')) {
		fix_up = fix_up.replace('\x07', "\\c6");
	}

	if (fix_up.canFind('\x0b')) {
		fix_up = fix_up.replace('\x0b', "\\c7");
	}

	if (fix_up.canFind('\x0c')) {
		fix_up = fix_up.replace('\x0c', "\\c8");
	}

	if (fix_up.canFind('\x0e')) {
		fix_up = fix_up.replace('\x0e', "\\c9");
	}

	fix_up = fix_up.replace("\"", "");

	string ret;

	if(!fix_up.isNumeric()) {
		ret = "\"" ~ fix_up ~ "\"";
	}
	else {
		ret = fix_up;
	}

	dec.i++;

	// Convert it to a tag here...
	if(dec.fi.code[dec.i] == opcode.OP_TAG_TO_STR) {
		ret = ret.replace("\"", "'");
	}

	dec.stacks.s_s ~= ret;

}

void loadimmed_flt(decompiler dec) {
	import std.conv : to;
	dec.stacks.f_s ~= to!string(dec.get_float(dec.fi.code[dec.i], dec.status.enteredFunction));
	dec.i++;
}

void loadimmed_ident(decompiler dec) {
	dec.stacks.s_s ~= dec.get_string(dec.fi.code[dec.i], false);
	dec.i++;
}

void loadvar_uint(decompiler dec) {
	dec.stacks.i_s ~= dec.status.current_variable;
}

void loadvar_str(decompiler dec) {
	dec.stacks.s_s ~= dec.status.current_variable;
}

void loadvar_flt(decompiler dec) {
	dec.stacks.f_s ~= dec.status.current_variable;
}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_LOADVAR_FLT] = &loadvar_flt;
	dec.handlers[opcode.OP_LOADVAR_STR] = &loadvar_str;
	dec.handlers[opcode.OP_LOADVAR_UINT] = &loadvar_uint;
	dec.handlers[opcode.OP_LOADIMMED_IDENT] = &loadimmed_ident;
	dec.handlers[opcode.OP_LOADIMMED_STR] = &loadimmed_str;
	dec.handlers[opcode.OP_LOADIMMED_UINT] = &loadimmed_uint;
	dec.handlers[opcode.OP_LOADIMMED_FLT] = &loadimmed_flt;
}



