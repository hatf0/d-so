import std.stdio;
import std.file;

File DSO;

void main(string[] args)
{
	writeln(args[1]);
	if(exists(args[1]))
	{
		writeln("file exists!");
		DSO = File(args[1], "r");
		auto buf = DSO.rawRead(new int[1]);
		string key = "c13buotro";
		if(buf[0] == 210)
		{
			writeln("version check pass");
			buf = DSO.rawRead(new int[1]);
			writeln("global string size: ", buf[0]);
			if(buf[0])
			{
				auto global_string_table = DSO.rawRead(new char[buf[0]]);
				for(int i = 0; i < buf[0]; i++)
				{
					global_string_table[i] ^= key[i % 9];
				}
			//writeln(global_string_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("global float size: ", buf[0]);
			if(buf[0])
			{
				auto global_float_table = DSO.rawRead(new double[buf[0]]);
				writeln(global_float_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("function string size: ", buf[0]);
			if(buf[0])
			{
				auto function_string_table = DSO.rawRead(new char[buf[0]]);
				for(int i = 0; i < buf[0]; i++)
				{
					function_string_table[i] ^= key[i % 9];
				}
				writeln(function_string_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("function float size: ", buf[0]);
			if(buf[0])
			{
				auto function_float_table = DSO.rawRead(new double[buf[0]]);
				writeln(function_float_table);
			}
			buf = DSO.rawRead(new int[1]);
			writeln("code size: ", buf[0]);
			auto line_break_pair_count = DSO.rawRead(new int[1])[0];
			writeln("line break pair count: ", line_break_pair_count);
			for(int i = 0; i < buf[0]; i++)
			{
				auto value = DSO.rawRead(new byte[1])[0];
				if(value == 0xFF)
				{
					auto qq = DSO.rawRead(new int[1])[0];
					writeln("INT! ", qq);
				}
				else
				{
					writeln("BYTE! ", value);
				}
			}
		}
		DSO.close();
	}
	else
	{
		writeln("file does not exist.");
	}
}
