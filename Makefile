rPackageName=ChoR
newDate=$(shell date +%Y-%m-%d)
rPackageVersion=$(shell grep "Version:" ./$(rPackageName)/DESCRIPTION | cut -c1-9 --complement)

check: cpjar roxy
	R CMD build $(rPackageName)
	R CMD check $(rPackageName)_$(rPackageVersion).tar.gz --as-cran

install: cpjar roxy
	R CMD build $(rPackageName)
	R CMD INSTALL $(rPackageName)_$(rPackageVersion).tar.gz

roxy:
	rm -f ./$(rPackageName)/man/*.Rd
	printf "library(roxygen2)\npath <- \"./$(rPackageName)/\"\nroxygenize(package.dir=path)\n" > tmp_roxy.R
	R CMD BATCH tmp_roxy.R
	cd ./$(rPackageName) && sed -i 's/\(Date: \).*/Date: '"$(newDate)"'/' DESCRIPTION
	cd ./$(rPackageName) && sed -i -e 's/\".registration=TRUE\"/.registration=TRUE/' NAMESPACE

##Note:
## If commented, created with compiled jar

cpjar: jar
#	cp ./java/choR.jar ./choR/inst/java/choR.jar
#	cp ./java/lib/core.jar ./choR/inst/java/core.jar
#	cp ./java/lib/core/commons-math3-3.2.jar ./choR/inst/java/commons-math3-3.2.jar
#	cp ./java/lib/core/jayes.jar ./choR/inst/java/jayes.jar
#	cp ./java/lib/core/jgrapht-jdk1.6.jar ./choR/inst/java/jgrapht-jdk1.6.jar

jar:
#	$(MAKE) all -C java

clean:
	rm -rf $(rPackageName)_$(rPackageVersion).tar.gz $(rPackageName).Rcheck
	rm -rf ./$(rPackageName)/man/*.Rd
	rm -rf ./tmp_roxy.R ./tmp_roxy.Rout
	rm -rf .RData
