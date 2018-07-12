module objects.getvar;
import bldso : decompiler;
import opcodes : opcode;

void loadfield(decompiler dec) {
	import std.algorithm : canFind;

	string currentObject = dec.status.current_object; //Just stored for ease of access
	string finalStatement;
	if(currentObject.canFind("$") || currentObject.canFind("%")) {
		finalStatement = currentObject ~ "." ~ dec.status.current_field;
	}
	else {
		finalStatement = "\"" ~ currentObject ~ "\"" ~ "." ~ dec.status.current_field;
	}


	switch(dec.status.currentOpcode) {
		case opcode.OP_LOADFIELD_UINT:
			dec.stacks.i_s ~= finalStatement;
			break;
		case opcode.OP_LOADFIELD_STR:
			dec.stacks.s_s ~= finalStatement;
			break;
		case opcode.OP_LOADFIELD_FLT:
			dec.stacks.f_s ~= finalStatement;
			break;
		default:
			break;
	}
}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_LOADFIELD_UINT] = &loadfield;
	dec.handlers[opcode.OP_LOADFIELD_STR] = &loadfield;
	dec.handlers[opcode.OP_LOADFIELD_FLT] = &loadfield;
}


