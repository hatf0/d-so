main: main.d bldso.d
	dmd main.d bldso.d 
	./main -f mainServer.cs.dso
