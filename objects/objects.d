module objects.objects;
import objects.creation;
import objects.getvar;
import objects.setvar;
import bldso : decompiler;

void registerAll(decompiler dec) {
	objects.creation.bootup(dec);
	objects.getvar.bootup(dec);
	objects.setvar.bootup(dec);
}
