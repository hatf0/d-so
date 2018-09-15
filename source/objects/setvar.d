module objects.setvar;
import bldso : decompiler;
import opcodes : opcode;
import utilities : addTabulation, popOffStack;

void savefield(ref decompiler dec) {
	string rhs;
	if(dec.status.currentOpcode == opcode.OP_SAVEFIELD_STR) {
		rhs = dec.stacks.s_s[dec.stacks.s_s.length - 1];
	}
	else if(dec.status.currentOpcode == opcode.OP_SAVEFIELD_FLT) {
		rhs = dec.stacks.f_s[dec.stacks.f_s.length - 1];
	}
	string currentObject = dec.status.current_object; //I'm lazy, okay?
	if(currentObject != "") { //We have an object in our sights..
		if(currentObject[0] == '$' || currentObject[0] == '%') {
			dec.fi.outputFile.writeln(addTabulation(currentObject ~ "." ~ dec.status.current_field ~ " = " ~ rhs ~ ";", dec.indentation));
		}
		else {
			dec.fi.outputFile.writeln(addTabulation("\"" ~ currentObject ~ "\"." ~ dec.status.current_field ~ " = " ~ rhs ~ ";", dec.indentation));
		}

	}
	else { //Never mind, it's probably a new object..
		if(dec.status.enteredObjCreation) {
			dec.stacks.i_s[dec.stacks.i_s.length - 1] ~= dec.status.current_field ~ " = " ~ rhs ~ ";";
		}
		else {
			//Erm.. this is awkward?
			dec.fi.outputFile.writeln(addTabulation(dec.status.current_field ~ " = " ~ rhs ~ ";", dec.indentation));
		}
	}

		
}

void setcurfield(ref decompiler dec) {
	dec.status.current_field = dec.get_string(dec.fi.code[dec.i], false);
	dec.i++;

}

void setcurobject(ref decompiler dec) {
	dec.status.current_object = popOffStack(dec.stacks.s_s);
}


void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_SAVEFIELD_STR] = &savefield;
	dec.handlers[opcode.OP_SAVEFIELD_FLT] = &savefield;
	dec.handlers[opcode.OP_SETCUROBJECT] = &setcurobject;
	dec.handlers[opcode.OP_SETCURFIELD] = &setcurfield;
}


