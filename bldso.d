module bldso;
import std.stdio;
import std.conv;
import std.array;
import core.exception;
import std.utf;

/*
   I'm not even going to try to document this file. It uses a ton of dirty hacks to achieve the output...
   Assume it's black magic. If there's a bug, report it on GitHub, and I'll use my summoning powers, and I'll do a blood sacrifice to Satan.
   Maybe then the bug will be fixed.
   How do I add Satan as a contributor on GitHub?
*/

enum opcodes {
	FILLER0,
	OP_ADVANCE_STR_NUL,
	OP_UINT_TO_STR,
	OP_UINT_TO_NONE,
	FILLER1,
	OP_ADD_OBJECT,
	FILLER2,
	OP_CALLFUNC_RESOLVE,
	OP_FLT_TO_UINT,
	OP_FLT_TO_STR,
	OP_STR_TO_NONE_2,
	OP_LOADVAR_UINT,
	OP_SAVEVAR_STR,
	OP_JMPIFNOT,
	OP_SAVEVAR_FLT,
	OP_LOADIMMED_UINT,
	OP_LOADIMMED_FLT,
	OP_LOADIMMED_IDENT,
	OP_TAG_TO_STR,
	OP_LOADIMMED_STR,
	OP_ADVANCE_STR_APPENDCHAR,
	OP_TERMINATE_REWIND_STR,
	OP_ADVANCE_STR,
	OP_CMPLE,
	OP_SETCURFIELD,
	OP_SETCURFIELD_ARRAY,
	OP_JMPIF_NP,
	OP_JMPIFF,
	OP_JMP,
	OP_BITOR,
	OP_SHL,
	OP_SHR,
	OP_STR_TO_NONE,
	OP_COMPARE_STR,
	OP_CMPEQ,
	OP_CMPGR,
	OP_CMPNE, 
	OP_OR,
	OP_STR_TO_UINT,
	OP_SETCUROBJECT,
	OP_PUSH_FRAME,
	OP_REWIND_STR,
	OP_LOADFIELD_UINT_2,
	OP_CALLFUNC,
	OP_LOADVAR_STR,
	OP_LOADVAR_FLT,
	OP_SAVEFIELD_FLT,
	OP_LOADFIELD_FLT,
	OP_MOD,
	OP_LOADFIELD_UINT,
	OP_JMPIFFNOT,
	OP_JMPIF,
	OP_SAVEVAR_UINT,
	OP_SUB,
	OP_MUL,
	OP_DIV,
	OP_NEG,
	FILLER3,
	OP_STR_TO_FLT,
	OP_END_OBJECT,
	OP_CMPLT,
	OP_BREAK,
	OP_SETCURVAR_CREATE,
	OP_SETCUROBJECT_NEW,
	OP_NOT,
	OP_NOTF,
	OP_SETCURVAR,
	OP_SETCURVAR_ARRAY,
	OP_ADD,
	OP_SETCURVAR_ARRAY_CREATE,
	OP_JMPIFNOT_NP,
	OP_AND,
	OP_RETURN,
	OP_XOR,
	OP_CMPGE,
	OP_LOADFIELD_STR,
	OP_SAVEFIELD_STR,
	OP_BITAND,
	OP_ONESCOMPLEMENT,
	OP_ADVANCE_STR_COMMA,
	OP_PUSH,
	OP_FLT_TO_NONE,
	OP_CREATE_OBJECT,
	OP_FUNC_DECL,
	DECOMPILER_ENDFUNC = 0x1111,
	DECOMPILER_ENDIF = 0x1337,
	DECOMPILER_ENDWHILE = 0x2222,
	DECOMPILER_ELSE = 0x3333,
	DECOMPILER_ENDWHILE_FLOAT = 0x4444, //Needed so we know what to pop off the stack.
	DECOMPILER_ENDIF_SHORTJMP = 0x5555,
	DECOMPILER_END_BINOP = 0x6666
}

enum CallTypes {
	FunctionCall, //A regular call. May have a namespace.
	ObjectCall, //Object and/or MethodCall
	ParentCall, //idk dude
	FunctionDecl //Something I just added in for shits and giggles tbh
}	

File curFile;
static int dbg = 0;

string[][] decompile(char[] global_st, char[] function_st, double[] global_ft, double[] function_ft, int[] code, int[] lbptable, string dso_name = "", bool entered_function = false, int offset = 0, int tablevel = 0) {
	import std.algorithm, std.string;
	//writeln("Code length: ", code.length);
	int i = 0;
	int verbosity = 0;
	int step_by_step = 0;
	bool create_folders = false;
	int indentation_level = tablevel;
	bool enteredFunction = entered_function, enteredObjectCreation = false; //Needed if we enter into an object creation for some reason?
	string[] string_stack;
	string[] int_stack;
	string[] float_stack;
	string[] bin_stack;
	string[][] arguments;
	int[] lookback_stack = [0, 0, 0, 0];
	string current_object = "", current_field = "", current_variable = "";
	string string_op(char inchar) {
		switch(inchar) {
			case '\n':
				return "NL";
			case '\t':
				return "TAB";
			case ' ':
				return "@";

			default:
				return "";
		}
	}

	string invertOperator(string op) {
		if(op.canFind(" != ")) {
			return op.replace("!=", "==");
		}
		if(op.canFind(" == ")) {
			return op.replace("==", "!=");
		}
		else if(op.canFind(" !$= ")) {
			return op.replace("!$=", "$=");
		}
		else if(op.canFind(" $= ")) {
			//curFile.writeln("ASS");
			return op.replace("$=", "!$=");
		}
		else if(op.canFind("!")) {
		//	curFile.writeln("let me");
			return op[1..op.length];
		}
		else if(!op.canFind("!")) {
			//curFile.writeln("stupid ass");
			return "!" ~ op;
		}
		//else if(op.canFind(" ")) {
		//	curFile.writeln("AAS");
		//	return "!(" ~ op ~ ")";
		//}
		//curFile.writeln("ASSS");
		return op;
	}
	string constructPrettyFunction(string fnName, string fnNamespace, string[] argv, CallTypes callType = CallTypes.FunctionCall) {
		string retVal = "";
		int i = 0;

		if(callType == CallTypes.ObjectCall) {
			if(argv[0].canFind(" ")) {
				retVal ~= "(" ~ argv[0] ~ ").";
			}
			else {
				retVal ~= argv[0] ~ ".";
			}
			//i = 1;
			if(argv.length != 1) {
				argv = argv[1..argv.length];
			}
			else {
				argv = [];
			}
		}
		if(fnNamespace != "") {
			retVal ~= fnNamespace ~ "::" ~ fnName;
		}
		else {
			retVal ~= fnName;
		}
		retVal ~= "(";
			if(argv.length == 1) {
				retVal ~= argv[0];
			}
			else {
				for(; i < argv.length; i++) {
					retVal ~= argv[i];
					if(i != argv.length - 1)
					{
						retVal ~= ", ";
					}
				}
			}

		retVal ~= ")";
		return retVal;
	}

	string popOffStack(ref string[] instack) {
		string ret;
		if(instack.length == 1) {
			ret = instack[0];
			instack = [];
		}
		else {
			ret = instack[instack.length - 1];
			instack = instack.remove(instack.length - 1);
		}
		return ret;
	}

	string getComparison(int opcode) {
		switch(opcode) {
			case opcodes.OP_CMPEQ: {
				return "==";
			}
			case opcodes.OP_CMPGE: {
				return ">=";
			}
			case opcodes.OP_CMPNE: {
				return "!=";
			}
			case opcodes.OP_CMPGR: {
				return ">";
			}
			case opcodes.OP_CMPLT: {
				return "<";
			}
			case opcodes.OP_CMPLE: {
				return "<=";
			}
			default: {
				return "";
			}
 		}
	}


	string get_string(int offset, bool fuck = enteredFunction) {
		//writeln()
		import std.regex;
		byte[] blehtable;
		if(!fuck) {
			blehtable = cast(byte[])global_st[offset..global_st.length];		
		}
		else {
			blehtable = cast(byte[])function_st[offset..function_st.length];
		}
		//string aaa = blehtable.idup;
		//blehtable = replaceAll(blehtable, regex(r"\\[uU]([0-9A-F]{4})"), "");
		//writeln(blehtable);
		int endPartOfString = cast(int)countUntil(blehtable, '\x00');
		//writeln("End portion of string: ", endPartOfString);
		//writeln("Attempt to slice out the string: ", blehtable[0..endPartOfString]);
		char[] slicedString = cast(char[])blehtable[0..endPartOfString];
		return text(slicedString.ptr);
	}

	float get_float(int offset, bool fuck = enteredFunction) {
		float retval;
		if(!fuck) {
			retval = global_ft[offset];
		}
		else {
			retval = function_ft[offset];
		}
		return retval;
	}

	string addTabulation(string previous) {
		string retVal = "";
		for(int l = 0; l < indentation_level; l++) {
			retVal ~= "\t";
		}
		retVal ~= previous;
		return retVal;
	}

	if(dso_name != "") { //If this happens, then, we're probably doing a partial decompile.
		int fileExtension = cast(int)countUntil(dso_name, ".cs.dso");
		string file_name_with_fixed_ext = dso_name[0..fileExtension] ~ ".cs";
		//writeln(dso_name[0..fileExtension]);{
		curFile = File(file_name_with_fixed_ext, "w");
	}
	while(i < code.length) {
		int what = i;
		opcodes opcode = cast(opcodes)code[i];
		i++;
		//Pop one off the front, then append it to the back.
		lookback_stack = lookback_stack.remove(0);
		lookback_stack.insertInPlace(3, opcode);
		if(step_by_step && dso_name != "") {
			writeln(to!string(opcode), " IP: ", what);
			std.stdio.stdin.readln();
		}
		//writeln(to!string(opcode));
		try {
			switch(opcode) {
				case opcodes.OP_FUNC_DECL: {
					string fnName = get_string(code[i]);
					string fnNamespace = get_string(code[i + 1]);
					if(code[i + 1] == 0) {
						fnNamespace = "";
					}
					string fnPackage = get_string(code[i + 2]);
					int has_body, fnEndLoc, argc;
					has_body = code[i + 3];
					fnEndLoc = code[i + 4];
					argc = code[i + 5];
					string[] argv;
					int whatWasThere = code[fnEndLoc];
					//code.insertBefore(fnEndLoc, opcodes_meta.DECOMPILER_ENDFUNC);
					code.insertInPlace(fnEndLoc, opcodes.DECOMPILER_ENDFUNC);
					//writeln("New function");
					//code[fnEndLoc] = opcodes_meta.DECOMPILER_ENDFUNC;
					//writeln(lookback_stack);
					//writeln("fnName: ", fnName, " fnNamespace: ", fnNamespace, " fnPackage: ", fnPackage, " has_body: ", has_body, " fnEndLoc: ", fnEndLoc, " argc ", argc);
					//writeln(global_st[code[i]]);
					//writeln(code[ip]);
					//writeln("Code end loc: ", fnEndLoc, " code size: ", code.length);
					//writeln("Thing at code end loc: ", code[fnEndLoc]);
					enteredFunction = true;
					if(code[fnEndLoc] == opcodes.DECOMPILER_ENDFUNC) {
						//writeln("fnEndLoc inserted successfully");
					}
					if(code[fnEndLoc + 1] == whatWasThere) {
						//writeln("OPCode directly after is saved..");
					}
					//writeln("Found a function declaration");
					for(int q = 0; q < argc; q++) {
						argv ~= get_string(code[i + 6 + q], false);
					//	argv ~= text(function_st[code[i + 6 + q]]);
					}
					curFile.writeln("function " ~ constructPrettyFunction(fnName, fnNamespace, argv) ~ " {");
					indentation_level++;
					//writeln(constructPrettyFunction(fnName, fnNamespace, argv));
					i += 6 + argc;
					if(dbg) {
						if(fnName == "directSelectInv") {
							step_by_step = 1;
						}
					}
					//decompile(global_st, function_st, global_ft, function_ft, code[i + 6 + argc..fnEndLoc - 2], lbptable, "", enteredFunction, i + 6 + argc, indentation_level);
					//i = fnEndLoc - 1;
					//writeln(argv);
					break;
				}

				case opcodes.DECOMPILER_ENDFUNC: { //our metadata that we inserted
					//writeln("encountered endfunc at ", i - 1);
					if(step_by_step) {
						step_by_step = 0;
					}
					code = code.remove(i - 1); //we encountered it, now delete it because offsets are fucky
					indentation_level = 0; //tabs or spaces??
					curFile.writeln(addTabulation("}\n"));
					//writeln("code at pos: ", code[i - 1]);
					enteredFunction = false;
					i--;
					break;
				}

				case opcodes.OP_CALLFUNC_RESOLVE, opcodes.OP_CALLFUNC: {
					int call_type = code[i + 2];
					//writeln("Got call type");
					//writeln(code[i], " ", enteredFunction ? function_st.length : global_st.length);
					string fnName = get_string(code[i], false);
					//writeln("Got fnName");
					string fnNamespace = "";
					//curFile.writeln(code[i + 1]);
					if(code[i + 1] != 0) {
						fnNamespace = get_string(code[i + 1], false);
					}
					//writeln(arguments);
					string[] argv = arguments[arguments.length - 1];
					arguments = arguments.remove(arguments.length - 1);
					//writeln(argv);
					string_stack ~= constructPrettyFunction(fnName, fnNamespace, argv, cast(CallTypes)call_type);
					i += 3;
					break;
				}

				case opcodes.OP_RETURN: {
					//writeln("return ", string_stack.length);
					//writeln(string_stack[string_stack.length]);
					if(!enteredFunction && !enteredObjectCreation) {
						break;
					}

					string writeOut = addTabulation("");
					string ret = "(NULL)";
					writeOut ~= "return";
					if(string_stack.length != 0) {
						ret = popOffStack(string_stack);
						writeOut ~= " " ~ ret ~ ";";
					}
					else {
						writeOut ~= ";";
					}
					//curFile.writeln("IP IS: " ~ text(i - 1));
					opcodes[] lbk = cast(opcodes[])lookback_stack;
					//curFile.writeln("STUFF BEFORE", to!string(lbk));
					if(ret != "(NULL)") {
						curFile.writeln(writeOut);
					}
					else if(i != code.length && code[i] != opcodes.DECOMPILER_ENDFUNC && i + 1 != code.length && lookback_stack[2] != opcodes.DECOMPILER_ENDFUNC) {
						curFile.writeln(writeOut);
					}
					else {
						if(dbg) {
							curFile.writeln(addTabulation("//IGNORED RETURN"));
						}
					}
					break;
				}

				case opcodes.OP_PUSH_FRAME: {
					arguments ~= [[]];
					//writeln(arguments);
					break;
				}

				case opcodes.OP_PUSH: {
					//if(lookback_stack[3] == opcodes.OP_LOADVAR_FLT || lookback_stack[3] == opcodes.OP_LOADVAR_STR || lookback_stack[3] == opcodes.OP_LOADVAR_FLT) {
					arguments[arguments.length - 1] ~= [popOffStack(string_stack)];
					break;
				}

				case opcodes.OP_CREATE_OBJECT: {
					string parent = get_string(code[i], false);
					int isDatablock = code[i + 1], failJump = code[i + 2];
					string[] argumentsFrame = arguments[arguments.length - 1];
					string constr = "new " ~ argumentsFrame[0] ~ "(" ~ argumentsFrame[1] ~ ")" ~ "{\n";
					int_stack ~= constr;
					enteredObjectCreation = true;
					indentation_level++;
					i += 3;
					arguments.remove(arguments.length - 1);

					break;
				}

				case opcodes.OP_END_OBJECT: {
					indentation_level--;
					i++;
					string op = popOffStack(int_stack);
					op ~= "};";
					enteredObjectCreation = false;
					break;
				}

				case opcodes.OP_ADD_OBJECT: {
					i++;
					break;
				}

				case opcodes.OP_SETCUROBJECT: {
					current_object = popOffStack(string_stack);
					break;
				}

				case opcodes.OP_SETCUROBJECT_NEW: {
					current_object = "";
					break;
				}

				case opcodes.OP_SETCURVAR, opcodes.OP_SETCURVAR_CREATE: {
					current_variable = get_string(code[i], false);
					i++;
					break;
				}

				case opcodes.OP_SETCURVAR_ARRAY, opcodes.OP_SETCURVAR_ARRAY_CREATE: {
					current_variable = popOffStack(string_stack);
					break;
				}

				case opcodes.OP_SETCURFIELD: {
					current_field = get_string(code[i], false);
					i++;
					break;
				}

				case opcodes.OP_SETCURFIELD_ARRAY: {
					auto hnng = popOffStack(string_stack);
					current_field ~= "[" ~ hnng ~ "]";
					break;
				}

				case opcodes.OP_LOADVAR_STR, opcodes.OP_LOADVAR_FLT, opcodes.OP_LOADVAR_UINT: {
					if(opcode == opcodes.OP_LOADVAR_STR) {
						string_stack ~= current_variable;
					}
					else if(opcode == opcodes.OP_LOADVAR_FLT) {
						float_stack ~= current_variable;
					}
					else if(opcode == opcodes.OP_LOADVAR_UINT) {
						int_stack ~= current_variable;
					}
					break;
				}

				case opcodes.OP_LOADIMMED_STR, opcodes.OP_TAG_TO_STR: {

					string bleh = get_string(code[i]);
					string str;
					if(bleh.canFind("\n")) {
						bleh = bleh.replace("\n", "\\n");
						//str = bleh;
					}

					if(bleh.canFind("\r")) {
						bleh = bleh.replace("\r", "\\r");
					}

					if(bleh.canFind("\t")) {
						bleh = bleh.replace("\t", "\\t");
					}

					//Color codes
					if(bleh.canFind("\x01")) {
						bleh = bleh.replace("\x01", "\\c0");
					}

					if(bleh.canFind("\x02")) {
						bleh = bleh.replace("\x02", "\\c1");
					}

					if(bleh.canFind("\x03")) {
						bleh = bleh.replace("\x03", "\\c2");
					}

					if(bleh.canFind("\x04")) {
						bleh = bleh.replace("\x04", "\\c3");
					}

					if(bleh.canFind("\x05")) {
						bleh = bleh.replace("\x05", "\\c4");
					}

					if(bleh.canFind("\x06")) {
						bleh = bleh.replace("\x06", "\\c5");
					}

					if(bleh.canFind("\x07")) {
						bleh = bleh.replace("\x07", "\\c6");
					}

					if(bleh.canFind("\x0B")) {
						bleh = bleh.replace("\x0B", "\\c7");
					}

					if(bleh.canFind("\x09")) {
						bleh = bleh.replace("\x09", "\\c8");
					}


					bleh = bleh.replace("\"", "");
					if(!bleh.isNumeric()) {
						str = "\"" ~ bleh ~ "\"";
					}
					else {
						str = bleh;
					}
					i++;
					if(opcode == opcodes.OP_TAG_TO_STR) {
						//Oops, lmao. This needs to be enclosed in single quotes to work properly with TS.
						//curFile.writeln("//TAG_TO_STR", str);
						str = str.replace("\"", "'");
					}

					string_stack ~= str;
					break;
				}

				case opcodes.OP_LOADIMMED_IDENT, opcodes.OP_LOADIMMED_FLT, opcodes.OP_LOADIMMED_UINT: {
					if(opcode == opcodes.OP_LOADIMMED_IDENT) {
						string_stack ~= get_string(code[i], false);
					}
					else if(opcode == opcodes.OP_LOADIMMED_FLT) {
						float_stack ~= to!string(get_float(code[i]));
					}
					else if(opcode == opcodes.OP_LOADIMMED_UINT) {
						int_stack ~= to!string(code[i]);
					}
					i++;
					break;
				}

				case opcodes.OP_LOADFIELD_STR, opcodes.OP_LOADFIELD_UINT, opcodes.OP_LOADFIELD_FLT: {
					string obj = current_object;
					string addition;
					if(obj.canFind("$") || obj.canFind("%")) {
						addition = obj ~ "." ~ current_field;
					}
					else {
						addition = "\"" ~ obj ~ "\"" ~ "." ~ current_field;
					}

					if(opcode == opcodes.OP_LOADFIELD_STR) {
						string_stack ~= addition;
					}
					else if(opcode == opcodes.OP_LOADFIELD_FLT) {
						float_stack ~= addition;
					}
					else {
						int_stack ~= addition;
					}
					break;
				}

				case opcodes.OP_STR_TO_NONE, opcodes.OP_FLT_TO_NONE, opcodes.OP_UINT_TO_NONE: {
					//writeln(string_stack);
					//Return value is ignored, so we can immediately write it out.
					//writeln(string_stack, " ", string_stack.length);
					string theFunc;
					if(opcode == opcodes.OP_STR_TO_NONE) {
						if(lookback_stack[2] == opcodes.OP_CALLFUNC_RESOLVE || lookback_stack[2] == opcodes.OP_CALLFUNC) {
							//writeln("lol");
							theFunc = addTabulation(popOffStack(string_stack));
						}
						else {
								//writeln(lookback_stack[2]);
								//writeln("lol2");
								popOffStack(string_stack);
								break;
						}
					}
					else if(opcode == opcodes.OP_FLT_TO_NONE) {
						popOffStack(float_stack);
						//theFunc = addTabulation(popOffStack(float_stack));
						break;
						//theFunc = addTabulation(popOffStack(float_stack));
					}
					else if(opcode == opcodes.OP_UINT_TO_NONE) {
						popOffStack(int_stack);
						//theFunc = addTabulation(popOffStack(int_stack));
						break;
						////theFunc = addTabulation(popOffStack(int_stack));
					}
					//writeln(theFunc);
					if(theFunc[theFunc.length - 1] != ";"[0]) {
						theFunc ~= ";";
					}
					curFile.writeln(theFunc);
					break;
				}

				case opcodes.OP_STR_TO_FLT, opcodes.OP_STR_TO_UINT: {
					if(opcode == opcodes.OP_STR_TO_FLT) {
						float_stack ~= popOffStack(string_stack);
					}
					else if(opcode == opcodes.OP_STR_TO_UINT) {
						int_stack ~= popOffStack(string_stack);
					}
					break;
				}

				case opcodes.OP_FLT_TO_STR, opcodes.OP_FLT_TO_UINT: {
					if(opcode == opcodes.OP_FLT_TO_STR) {
						string_stack ~= popOffStack(float_stack);
					}
					else if(opcode == opcodes.OP_FLT_TO_UINT) {
						int_stack ~= popOffStack(float_stack);
					}
					break;
				}

				case opcodes.OP_UINT_TO_STR: {
					string_stack ~= popOffStack(int_stack);
					break;
				}

				case opcodes.OP_SAVEVAR_UINT, opcodes.OP_SAVEVAR_FLT, opcodes.OP_SAVEVAR_STR: {
					string part2;
					if(opcode == opcodes.OP_SAVEVAR_UINT) {
						part2 = int_stack[int_stack.length - 1];
					}
					else if(opcode == opcodes.OP_SAVEVAR_FLT) {
						part2 = float_stack[float_stack.length - 1];
					}
					else if(opcode == opcodes.OP_SAVEVAR_STR) {
						part2 = string_stack[string_stack.length - 1];
					}
					if(part2[part2.length - 1] != ";"[0]) { //lmfao
						part2 ~= ";";
					}
					curFile.writeln(addTabulation(current_variable ~ " = " ~ part2));
					break;
				}

				case opcodes.OP_JMP: {
					int jmp_target = code[i - 2] - offset; //Add this in for partial decompilation.
					code.insertInPlace(jmp_target, opcodes.DECOMPILER_ENDWHILE);
					curFile.writeln(addTabulation("break;"));
					i++;
					break;
				}

				case opcodes.OP_JMPIF: {
					i++;
					break;
				}

				case opcodes.OP_JMPIF_NP: {
					if(dbg) {
						curFile.writeln(addTabulation("//JMPIF_NP"));
					}
					bin_stack ~= popOffStack(int_stack) ~ " || ";
					int jmp_target = code[i] - offset;
					code.insertInPlace(jmp_target, opcodes.DECOMPILER_END_BINOP); 
					i++;
					break;
				}

				case opcodes.OP_JMPIFNOT_NP: {
					if(dbg) {
						curFile.writeln(addTabulation("JMPIFNOT_NP"));
					}
					bin_stack ~= popOffStack(int_stack) ~ " && ";
					int jmp_target = code[i] - offset;
					code.insertInPlace(jmp_target, opcodes.DECOMPILER_END_BINOP); 
					i++;
					break;
				}

				case opcodes.DECOMPILER_END_BINOP: {
					if(code[i - 1] == opcodes.DECOMPILER_END_BINOP) {
						code.remove(i - 1);
					}
					i--;
					string operator = popOffStack(bin_stack);
					string op_2 = "";
					if(int_stack.length > 0) {
						op_2 = popOffStack(int_stack);
					}
					else if(float_stack.length > 0) {
						op_2 = popOffStack(float_stack);
					}
					else if(string_stack.length > 0) {
						op_2 = popOffStack(string_stack);
					}

					if(op_2.canFind("&&") || op_2.canFind("||")) {
						op_2 = "(" ~ op_2 ~ ")";
					}
					int_stack ~= operator ~ op_2;
					break;

				}
								     					

				case opcodes.OP_JMPIFNOT, opcodes.OP_JMPIFFNOT: {
					int jmp_target = code[i] - offset;
					if(jmp_target < (i - 1) - offset) {
						writeln("backwards jump encountered");
						return [[]];
					}
					if(step_by_step && dbg) {
						curFile.writeln("//", i, " ", jmp_target, " ", offset);
					}
					if(jmp_target == i + 1) {
						if(dbg) {
							curFile.writeln("//", to!string(cast(opcodes)code[jmp_target]));
						}
						if(code[jmp_target] == opcodes.OP_RETURN) {
							if(opcode == opcodes.OP_JMPIFFNOT) {
								curFile.writeln(addTabulation("if (" ~ popOffStack(float_stack) ~ ") {"));
							}
							else {
								curFile.writeln(addTabulation("if (" ~ popOffStack(int_stack) ~ ") {"));
							}
							curFile.writeln(addTabulation("\treturn;"));
							curFile.writeln(addTabulation("}"));
							i = jmp_target + 1;
							break;
						}
						if(dbg) {
							curFile.writeln("//Skipped, empty");
						}
						i++;
						if(opcode == opcodes.OP_JMPIFNOT) {
							popOffStack(int_stack);
						}
						else {
							popOffStack(float_stack);
						}
						break;
					}

					int op_before_dest = code[jmp_target - 2];
			
					int op_before_jmp = code[jmp_target - 4];
					if(step_by_step) {
						curFile.writeln("//OP_BEFORE_DEST ", to!string(cast(opcodes)op_before_dest));
						curFile.writeln("//POS OF OP_BEFORE_DEST: ", jmp_target - 2);
						curFile.writeln("//OP_BEFORE_JMP ", to!string(cast(opcodes)op_before_jmp));
						curFile.writeln("//POS OF OP_BEFORE_JMP: ", jmp_target - 4);
					}

					if(jmp_target - 4 == i) {
						//Short jump.
						if(dbg) {
							curFile.writeln("//VERY SHORT JUMP!!");
						
							for(int q = i - 5; q < i + 8; q++) {
								if(q == i) {
									curFile.writeln("//CUR IP: ", q, " : ", to!string(cast(opcodes)code[q]));
								}
								else {
									curFile.writeln("//", q, " : ", to!string(cast(opcodes)code[q]));
								}
							}
							//Just assume that it's an if statement.
							curFile.writeln("//JMP_IP: " ~ to!string(jmp_target));
						}
						if(opcode == opcodes.OP_JMPIFNOT) {	
							curFile.writeln(addTabulation("if (" ~ popOffStack(int_stack) ~ ") {"));
						}
						else {
							curFile.writeln(addTabulation("if (" ~ popOffStack(float_stack) ~ ") {"));
						}
						indentation_level++;
						//code[jmp_target - 1] = opcodes.DECOMPILER_ENDIF;
						code.insertInPlace(jmp_target, opcodes.DECOMPILER_ENDIF);
						if(code[jmp_target + 1] == opcodes.OP_JMPIFNOT) {
							//Issa else stuffz
							//We should probably rewrite the opcodes here
							op_before_dest = code[jmp_target - 1];
							code[jmp_target - 2] = opcodes.DECOMPILER_ELSE;
							if(dbg) { 
								curFile.writeln("//INSERTING IT INTO THE JMP_TARGET");
							}
							code.insertInPlace(jmp_target, opcodes.DECOMPILER_ENDIF_SHORTJMP);
						}
						curFile.writeln(addTabulation("//Decompiler has exhausted all handling methods. This may be incorrect."));
						i++;
						break;
						//i++;
					}
						if(op_before_dest == opcodes.OP_JMP) {
							//curFile.writeln("//DBG: OP_JMP");

							if(op_before_jmp == opcodes.OP_LOADIMMED_UINT || op_before_jmp == opcodes.OP_LOADIMMED_FLT || op_before_jmp == opcodes.OP_LOADIMMED_STR || op_before_jmp == opcodes.OP_LOADIMMED_IDENT) {
								//curFile.writeln("Begin the partial decompile");
								string[][] bleh = decompile(global_st, function_st, global_ft, function_ft, code[i + 1..jmp_target - 1], lbptable, "", enteredFunction, i + 1, indentation_level);
								if(dbg) {
									curFile.writeln("//Partial decompile");
								}
								string[] s_s = bleh[0];
								string[] i_s = bleh[1];
								string[] f_s = bleh[2];
								if(s_s.length == 2) {
									string quick_pop = popOffStack(s_s);
									string_stack ~= "(" ~ (opcode == opcodes.OP_JMPIFNOT) ? popOffStack(int_stack) : popOffStack(float_stack) ~  ") ? " ~ popOffStack(s_s) ~ " : " ~ quick_pop;
									i = code[jmp_target - 1];
									break;
								}
								else if(i_s.length == 2) {
									string quick_pop = popOffStack(i_s);
									int_stack ~= "(" ~ (opcode == opcodes.OP_JMPIFNOT) ? popOffStack(int_stack) : popOffStack(float_stack) ~  ") ? " ~ popOffStack(i_s) ~ " : " ~ quick_pop;
									i = code[jmp_target - 1];
									break;
								}
								else if(f_s.length == 2) {
									string quick_pop = popOffStack(f_s);
									float_stack ~= "(" ~ (opcode == opcodes.OP_JMPIFNOT) ? popOffStack(int_stack) : popOffStack(float_stack) ~  ") ? " ~ popOffStack(f_s) ~ " : " ~ quick_pop;
									i = code[jmp_target - 1];
									break;
								}
							}

							if(jmp_target == i + 3) {
								if(dbg) {
									curFile.writeln(addTabulation("//DBG: empty body, inverting operation."));
								}	
								if(opcode == opcodes.OP_JMPIFNOT) {
									//curFile.writeln("OP_JMPIFNOT");
									string poppedOff = popOffStack(int_stack);
									//curFile.writeln(poppedOff);
									curFile.writeln(addTabulation("if (" ~ invertOperator(poppedOff) ~ ") {"));
								}
								else if(opcode == opcodes.OP_JMPIFFNOT) {
									//writeln("Just popping off the float stack, my dude.");
									//writeln(float_stack);
									string poppedOff = popOffStack(float_stack);
									//curFile.writeln(poppedOff);
									curFile.writeln(addTabulation("if (" ~ invertOperator(poppedOff) ~ ") {"));
								}
								code[jmp_target - 2] = opcodes.DECOMPILER_ELSE;
								i = jmp_target - 1;
								//curFile.writeln(code[jmp_target - 1]);
								code.insertInPlace(code[jmp_target - 1], opcodes.DECOMPILER_ENDIF);

							}
							else {
								if(opcode == opcodes.OP_JMPIFNOT) {
									//curFile.writeln("OP_JMPIFNOT");
									curFile.writeln(addTabulation("if (" ~ popOffStack(int_stack) ~ ") {"));
								}
								else if(opcode == opcodes.OP_JMPIFFNOT) {
									//writeln("Just popping off the float stack, my dude.");
									//writeln(float_stack);
									curFile.writeln(addTabulation("if (" ~ popOffStack(float_stack) ~ ") {"));
								}
								if(dbg) {
									curFile.writeln(addTabulation("//POSSIBLE BUG HERE"));
								}
								code[jmp_target - 2] = opcodes.DECOMPILER_ELSE;
								//curFile.writeln(code[jmp_target - 1]);
								code.insertInPlace(code[jmp_target - 1], opcodes.DECOMPILER_ENDIF);
							}
							indentation_level++;
						}
						else if(op_before_dest == opcodes.OP_JMPIFNOT || op_before_dest == opcodes.OP_JMPIF) {
							//writeln(int_stack.length);
							curFile.writeln(addTabulation("while(" ~ popOffStack(int_stack) ~ ") {"));
							indentation_level++;
							code[jmp_target - 2] = opcodes.DECOMPILER_ENDWHILE;
						}
						else if(op_before_dest == opcodes.OP_JMPIFF || op_before_dest == opcodes.OP_JMPIFFNOT) {
								curFile.writeln(addTabulation("while(" ~ popOffStack(float_stack) ~ ") {"));
								indentation_level++;
								code[jmp_target - 2] = opcodes.DECOMPILER_ENDWHILE;
						}
						else {
							//curFile.writeln("//DBG: FALLBACK");
							if(opcode == opcodes.OP_JMPIFNOT) {
								curFile.writeln(addTabulation("if (" ~ popOffStack(int_stack) ~ ") {"));
							}
							else if(opcode == opcodes.OP_JMPIFFNOT) {
								curFile.writeln(addTabulation("if (" ~ popOffStack(float_stack) ~ ") {"));
							}
							indentation_level++;
							code.insertInPlace(jmp_target, opcodes.DECOMPILER_ENDIF);
						}
					i++;
					break;
				}

				case opcodes.DECOMPILER_ELSE: {
					indentation_level--;
					curFile.writeln(addTabulation("}"));
					curFile.writeln(addTabulation("else {"));
					indentation_level++;
					i++;
					break;
				}

				case opcodes.DECOMPILER_ENDIF, opcodes.DECOMPILER_ENDWHILE, opcodes.DECOMPILER_ENDWHILE_FLOAT, opcodes.DECOMPILER_ENDIF_SHORTJMP: {
					indentation_level--;
					curFile.writeln(addTabulation("}"));
					if(opcode == opcodes.DECOMPILER_ENDWHILE) {
						if(int_stack.length > 0) {
							popOffStack(int_stack);
						}
						i++;
					}
					else if(opcode == opcodes.DECOMPILER_ENDWHILE_FLOAT) {
						if(float_stack.length > 0) {
							popOffStack(float_stack);
						}
						i++;
					}
					else if(opcode == opcodes.DECOMPILER_ENDIF_SHORTJMP) {
						code = code.remove(i - 1);
						i--;
					}
					else {
						code = code.remove(i - 1);
						i--;
					}
					break;
				}

				case opcodes.OP_SAVEFIELD_STR, opcodes.OP_SAVEFIELD_FLT: {
					string thing;
					if(opcode == opcodes.OP_SAVEFIELD_STR) {
						//writeln("Breathing you in when I want you out.");
						//writeln(string_stack.length);
						thing = string_stack[string_stack.length - 1];
					}
					else {
						thing = float_stack[float_stack.length - 1];
					}
					if(current_object != "") {
						//writeln("Test");
						if(current_object[0] == '$' || current_object[0] == '%') {
							curFile.writeln(addTabulation(current_object ~ "." ~ current_field ~ " = " ~ thing ~ ";"));
						}
						else {
							curFile.writeln(addTabulation("\"" ~ current_object ~ "\"" ~ "." ~ current_field ~ " = " ~ thing ~ ";"));
						}
					}
					else {
						//Then we're in an object creation.
						//writeln("Tired of home");
						if(enteredObjectCreation) {
							//writeln("in object creation");
							int_stack ~= popOffStack(int_stack) ~ current_field ~ " = " ~ thing ~ ";";
						}
						else {
							curFile.writeln(addTabulation(current_field ~ " = " ~ thing ~ ";"));
						}
					}
					break;
				}

				case opcodes.OP_COMPARE_STR: {
					string after = popOffStack(string_stack); //???
					int_stack ~= popOffStack(string_stack) ~ " $= " ~ after;
					break;
				}

				case opcodes.OP_REWIND_STR: {
					if(code[i] == opcodes.OP_SETCURVAR_ARRAY || code[i] == opcodes.OP_SETCURVAR_ARRAY_CREATE) {
						string after = popOffStack(string_stack);
						string_stack ~= popOffStack(string_stack) ~ "[" ~ after ~ "]";
					}
					else {
						string part2 = popOffStack(string_stack), part1 = popOffStack(string_stack);
						if(string_op(part1[part1.length - 1]) != "") {
							//curFile.writeln("yeah");
							string_stack ~= part1[0..part1.length - 1] ~ " " ~ string_op(part1[part1.length - 1]) ~ " " ~ part2;
						}
						else if(part1[part1.length - 1] == ',') {
							string_stack ~= part1 ~ part2;
						}
						else {
							string_stack ~= part1 ~ " @ " ~ part2;
						}
					}
					//writeln(string_stack);
					break;

				}

				case opcodes.OP_ADVANCE_STR_COMMA: {
					string_stack ~= popOffStack(string_stack) ~ ",";
					break;
				}

				case opcodes.OP_ADVANCE_STR_APPENDCHAR: {
					string_stack ~= popOffStack(string_stack) ~ cast(char)code[i];
					i++;
					break;
				}

				case opcodes.OP_CMPGE, opcodes.OP_CMPLT, opcodes.OP_CMPNE, opcodes.OP_CMPGR, opcodes.OP_CMPLE, opcodes.OP_CMPEQ: {
					string o1 = popOffStack(float_stack);
					string o2 = popOffStack(float_stack);
					int_stack ~= o1 ~ " " ~ getComparison(opcode) ~ " " ~ o2;
					break;
				}

				case opcodes.OP_ADD: {
					float_stack ~= popOffStack(float_stack) ~ " + " ~ popOffStack(float_stack);
					break;
				}

				case opcodes.OP_SUB: {
					float_stack ~= popOffStack(float_stack) ~ " - " ~ popOffStack(float_stack);
					break;
				}

				case opcodes.OP_NEG: {
					string operand = popOffStack(float_stack);

					if(operand[0] == '-') {
						float_stack ~= operand[1..operand.length];
					}
					else {
						float_stack ~= "-" ~ operand;
					}
					break;
				}

				case opcodes.OP_MOD: {
					string op = popOffStack(int_stack);
					int_stack ~= popOffStack(int_stack) ~ " % " ~ op; 
					break;
				}

				case opcodes.OP_MUL, opcodes.OP_DIV: {
					//curFile.writeln(lookback_stack);
					//curFile.writeln(float_stack);
					//curFile.writeln("hi");
					string op = popOffStack(float_stack);
					//curFile.writeln(op);
					if(op.canFind("+") || op.canFind("-")) {
						op = "(" ~ op ~ ")";
					}
					string op2 = popOffStack(float_stack);
					//curFile.writeln(op2);
					if(op2.canFind("+") || op2.canFind("-")) {
						op2 = "(" ~ op2 ~ ")";
					}
					string type = "";
					if(opcode == opcodes.OP_MUL) {
						type = " * ";
					}
					else {
						type = " / ";
					}

					float_stack ~= op ~ type ~ op2;
					//curFile.writeln(float_stack);
					break;
				}

				case opcodes.OP_BITAND, opcodes.OP_BITOR: {
					int_stack ~= popOffStack(int_stack) ~ (opcode == opcodes.OP_BITAND ? " & " : " | ") ~ popOffStack(int_stack);
					break;
				}

				case opcodes.OP_SHR: {
					int_stack ~= popOffStack(int_stack) ~ " << " ~ popOffStack(int_stack);
					break;
				}

				case opcodes.OP_NOT: {
					string op = popOffStack(int_stack);
					if(op.canFind("==")) {
						int_stack ~= op.replace("==", "!=");
					}
					else if(op.canFind("!=")) {
						int_stack ~= op.replace("!=", "==");
					}
					else if(op.canFind("$=")) {
						int_stack ~= op.replace("$=", "!$=");
					}
					else if(op.canFind("!$=")) {
						int_stack ~= op.replace("!$=", "$=");
					}
					else if(!op.canFind("!")) {
						int_stack ~= "!" ~ op;
					}
					else if(op.canFind(" ")) {
						int_stack ~= "!(" ~ op ~ ")";
					}
					else {
						int_stack ~= op[1..op.length];
					}
					break;
				}

				case opcodes.OP_NOTF: {
					string op = popOffStack(float_stack);
					if(op.canFind("!")) {
						int_stack ~= op[1..op.length];
					}
					else {
						int_stack ~= "!" ~ op;
					}
					break;

				}

				default: {
					break;
				//writeln("Unhandled");
				}
			}
		}
		catch(RangeError) {
			writeln("Encountered a RangeError.. at ip: ", what + offset);
			writeln("Encountered in: ", to!string(opcode));
			//writeln(code[i + 2]);
			if(offset != 0) {
				curFile.writeln(addTabulation("//PARTIAL DECOMPILE FAIL"));
			}
			else {
				curFile.close();
			}
			writeln(function_st.length);
			return [[]];
		}
		curFile.flush();
	}

	if(dso_name != "") {
		writeln("Done!");
		//writeln(arguments);
		//writeln(lookback_stack);
		//writeln(string_stack);
		curFile.close();
		return [[]];
	}
	else {
		return [string_stack, int_stack, float_stack];
	}
	//writeln("todo");
}
