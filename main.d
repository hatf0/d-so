import std.stdio;
import std.file;
import std.encoding;
import bldso;
import core.bitop;
import std.string;
import std.system;
import std.bitmanip;

File DSO;

void main(string[] args)
{
	version(LittleEndian) {
		writeln("Little endian detected");
	}
	version(BigEndian) {
		writeln("Big endian detected");
	}
	writeln(args[1]);
	if(exists(args[1]))
	{
		writeln("file exists!");
		DSO = File(args[1], "r");
		char[][] global_st;
		char[][] function_st;
		double[] global_ft;
		double[] function_ft;
		int[] code_table;
		int[] lbp_table;
		auto buf = DSO.rawRead(new int[1]);
		string key = "cl3buotro";
		ulong[string] dict;
		if(buf[0] == 210)
		{
			writeln("version check pass");
			buf = DSO.rawRead(new int[1]);
			writeln("global string size: ", buf[0]);
			if(buf[0])
			{
				char[] global_string_table = DSO.rawRead(new char[buf[0]]);
				for(int i = 0; i < buf[0]; i++) {
					//writeln(bigEndianToNative!ubyte([global_string_table[i]]), key[i % 9], global_string_table[i] ^ key[i % 9]);
					global_string_table[i] ^= key[i % 9];
				}
				//transcode(global_string_table, instignia);
				global_st = global_string_table.split('\x00');
			//	writeln(instignia.split('\x00'));
			//	writeln(global_string_table.split('\x00'));
			}
			buf = DSO.rawRead(new int[1]);
			writeln("global float size: ", buf[0]);
			if(buf[0])
			{
				auto global_float_table = DSO.rawRead(new double[buf[0]]);
				global_ft = global_float_table;
				writeln(global_float_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("function string size: ", buf[0]);
			if(buf[0])
			{
				char[] function_string_table = DSO.rawRead(new char[buf[0]]);
				for(int i = 0; i < buf[0]; i++)
				{
					function_string_table[i] ^= key[i % 9];
				}
				function_st = function_string_table.split('\x00');
				//writeln(function_string_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("function float size: ", buf[0]);
			if(buf[0])
			{
				auto function_float_table = DSO.rawRead(new double[buf[0]]);
				function_ft = function_float_table;
				writeln(function_float_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("code size: ", buf[0]);
			auto line_break_pair_count = DSO.rawRead(new int[1])[0];
			writeln("line break pair count: ", line_break_pair_count);
			int[] code;
			for(int i = 0; i < buf[0]; i++)
			{
				int value = cast(int)(DSO.rawRead(new ubyte[1])[0]);
				if(value == 0xFF) {
					writeln("0xff");
					value = DSO.rawRead(new int[1])[0];
				}
				code ~= value;
				//writeln(value);
			}

			int[] lbptable;
			for(int i = 0; i < line_break_pair_count * 2; i++)
			{
				int val = DSO.rawRead(new int[1])[0];
				lbptable ~= val;
			}
			buf = DSO.rawRead(new int[1]);
			for(int i = 0; i < buf[0]; i++) {
				auto stuff = DSO.rawRead(new int[2]);
				for(int q = 0; q < stuff[1]; q++) {
					auto locPath = DSO.rawRead(new int[1])[0];
					code[locPath] = stuff[0];
					//writeln("PATCHED ", locPath);
				}
			}
			code_table = code;
			lbp_table = lbptable;
		}
		else {
			writeln("Wrong DSO version.");
			return;
		}

		decompile(global_st, function_st, global_ft, function_ft, code_table, lbp_table);

		DSO.close();
	}
	else
	{
		writeln("file does not exist.");
	}
}
