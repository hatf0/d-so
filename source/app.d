import std.stdio;
import std.file;
import bldso;
import std.string;
import std.getopt;

File DSO;
string file;

void main(string[] args)
{
	if(args.length != 2) {
		writeln("hey bitch give me a file");
		return;
	}

	file = args[1];
	
	if(exists(file))
	{
		DSO = File(file, "r");
		char[] global_st; //The Global String Table is basically just one giant string delimited with null-terminators... but splitting it up into individual strings won't work.
		char[] function_st; //Function String Table, for stack-allocated variables, etc..
		double[] global_ft; //Global float table, all floats used in variables and such
		double[] function_ft; //Function float table, all floats used in local variables, arguments, blah..
		int[] code_table; //The actual opcode table
		int[] lbp_table; //Line break pair table
		auto buf = DSO.rawRead(new int[1]); //Read the version
		string key = "cl3buotro"; //String table decryption key
		if(buf[0] == 210) //Check if the DSO version is 210
		{
			buf = DSO.rawRead(new int[1]); //If it is, read the size of the global string table
			if(buf[0]) //Make sure it's not 0
			{
				char[] global_string_table = DSO.rawRead(new char[buf[0]]); //Read the entirety of it..
				for(int i = 0; i < buf[0]; i++) {
					global_string_table[i] ^= key[i % 9]; //Then decrypt it
				}
				global_st = global_string_table; //Now, set the decrypted version to the variable we're going to pass to the decompiler.
			}
			buf = DSO.rawRead(new int[1]); //Read the size of the global float table
			if(buf[0])
			{
				global_ft = DSO.rawRead(new double[buf[0]]); //Then read it all out into one massive double[] array
			}
			buf = DSO.rawRead(new int[1]); //Read the size of the function string table
			if(buf[0])
			{
				char[] function_string_table = DSO.rawRead(new char[buf[0]]); //Read it all..
				for(int i = 0; i < buf[0]; i++)
				{
					function_string_table[i] ^= key[i % 9]; //And decrypt it.
				}
				function_st = function_string_table; //Copy over the decrypted version
			}
			buf = DSO.rawRead(new int[1]); //Read the size of the function float table
			if(buf[0])
			{
				function_ft = DSO.rawRead(new double[buf[0]]);
			}
			buf = DSO.rawRead(new int[1]); //Now, read out the amount of opcodes in this file
			auto line_break_pair_count = DSO.rawRead(new int[1])[0] * 2; //And the line break pair count (times it by 2, because it's pairs!)
			int[] code;
			for(int i = 0; i < buf[0]; i++)
			{
				int value = cast(int)(DSO.rawRead(new ubyte[1])[0]); //Read a single byte
				if(value == 0xFF) { //This means it's an integer.
					value = DSO.rawRead(new int[1])[0]; //Read the actual integer
				}
				code ~= value; //Now, append it to the code table.
			}

			int[] lbptable; 
			for(int i = 0; i < line_break_pair_count; i++)
			{
				int val = DSO.rawRead(new int[1])[0]; //Now, read em all, and append it to the line break pair table.
				lbptable ~= val;
			}
			buf = DSO.rawRead(new int[1]); //Read the amount of places where string table entries need to be patched.
			for(int i = 0; i < buf[0]; i++) {
				auto stuff = DSO.rawRead(new int[2]); //Offset + count, offset being the offset inside the corresponding string table, count being amount of times referenced.
				for(int q = 0; q < stuff[1]; q++) {
					auto locPath = DSO.rawRead(new int[1])[0]; //Get the position of the opcode that needs to be replaced
					code[locPath] = stuff[0]; //Now fix it, so it properly refers to the correct string.
				}
			}
			code_table = code; //Hand off the fixed code table..
			lbp_table = lbptable; //As well as the line break pair table
		}
		else {
			writeln("Wrong DSO version.");
			return;
		}

		dec = new decompiler(global_st, function_st, function_ft, global_ft, code_table, lbp_table, DSO);
		dec.decompile();
	}
	else
	{
		writeln("file does not exist.");
	}
 }
