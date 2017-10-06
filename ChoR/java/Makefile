compile:
	mkdir -p bin
	find -name "*.java" -exec javac -d bin -cp "./lib/*:./lib/core/*" {} +

jar:
	cd bin && jar xf ../lib/core.jar
	jar vcf choR.jar -C bin .

all: compile jar

clean:
	rm -rf bin

proper:clean
	rm -f choR.jar
