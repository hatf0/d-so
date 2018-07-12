module variables.variables;
import variables.arrays;
import variables.loadvar;
import variables.savevar;
import bldso : decompiler;

void registerAll(decompiler dec) {
	variables.arrays.bootup(dec);
	variables.loadvar.bootup(dec);
	variables.savevar.bootup(dec);
}

