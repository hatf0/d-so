module special.special;
import bldso : decompiler;
import special.dechandlers;

void registerAll(ref decompiler dec) {
    special.dechandlers.bootup(dec);
}

