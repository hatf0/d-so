module functions.functions;
import bldso : decompiler;
import functions.decl;
import functions.resolve;

void registerAll(decompiler dec) 
{
	functions.decl.bootup(dec);
	functions.resolve.bootup(dec);
}

