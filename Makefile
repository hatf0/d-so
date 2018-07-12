SRCS=$(wildcard *.d) $(wildcard */*.d)
main: $(SRCS)
	dmd -J=./ -g -of=$@ $^
	./main -f ./mainServer.cs.dso
