rPackageName=ChoR
newDate=$(shell date +%Y-%m-%d)
rPackageVersion=$(shell grep "Version:" ./$(rPackageName)/DESCRIPTION | cut -c1-9 --complement)

check: cpjar roxy
	R-devel CMD build $(rPackageName)
	R-devel CMD check $(rPackageName)_$(rPackageVersion).tar.gz --as-cran

install: cpjar roxy
	R-devel CMD build $(rPackageName)
	R-devel CMD INSTALL $(rPackageName)_$(rPackageVersion).tar.gz

# Use roxygen to create the doc and NAMESPACE
# Update the DESCRIPTION file with the current date
# Update the NAMESPACE file with the import for rJava and commonsMath
roxy:
	rm -f ./$(rPackageName)/man/*.Rd
	printf "library(roxygen2)\npath <- \"./$(rPackageName)/\"\nroxygenize(package.dir=path)\n" > tmp_roxy.R
	R-devel CMD BATCH tmp_roxy.R
	cd ./$(rPackageName) && sed -i 's/\(Date: \).*/Date: '"$(newDate)"'/' DESCRIPTION
	cd ./$(rPackageName) && sed -i 's/\".registration=TRUE\"/.registration=TRUE/' NAMESPACE
	cd ./$(rPackageName) && sed -i '1s/^/import(rJava)\nimport(commonsMath)\n/' NAMESPACE

# Copy the jar from the source folder to the installation folder
cpjar: ./ChoR/java/choR.jar
	mkdir -p ./$(rPackageName)/inst/java
	cp ./$(rPackageName)/java/choR.jar                     ./$(rPackageName)/inst/java/choR.jar
	cp ./$(rPackageName)/java/lib/core.jar                 ./$(rPackageName)/inst/java/core.jar
	cp ./$(rPackageName)/java/lib/core/jayes.jar           ./$(rPackageName)/inst/java/jayes.jar
	cp ./$(rPackageName)/java/lib/core/jgrapht-jdk1.6.jar  ./$(rPackageName)/inst/java/jgrapht-jdk1.6.jar

# Compile the choR adapter
./$(rPackageName)/java/choR.jar:
	 $(MAKE) all -C ./$(rPackageName)/java

proper:
	rm -rf $(rPackageName)_$(rPackageVersion).tar.gz $(rPackageName).Rcheck
	rm -rf ./$(rPackageName)/man/*.Rd
	rm -rf ./tmp_roxy.R ./tmp_roxy.Rout
	rm -rf .RData
	rm -rf ./$(rPackageName)/inst/java
	$(MAKE) proper -C ./$(rPackageName)/java
