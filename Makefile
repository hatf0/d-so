main: main.d bldso.d
	dmd main.d bldso.d 
	./main mainServer.cs.dso
