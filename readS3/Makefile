all: main
readS3.o: readS3.cc readS3.h
	g++ -O2 -c readS3.cc
main.o: main.cc readS3.o
	g++ -O2 -c main.cc
main: main.o readS3.o
	g++ -O2 -o main main.o readS3.o
