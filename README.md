# ChoR, a R package for [ Chordalysis ]( https://github.com/fpetitjean/Chordalysis )
ChoR is a R package for the [ Chordalysis ]( https://github.com/fpetitjean/Chordalysis ) algorithm,
developed at Monash University.



## About [rJava](https://www.rforge.net/rJava/)
The Chordalysis algorithm is coded in Java.
This package contains an R layer allowing to use the java code through [rJava](https://www.rforge.net/rJava/).

The rJava package can be install in R with:
```R
install.packages('rJava')
```

R may need to be reconfigure with Java support. In the shell (may require sudo):
```shell
R CMD javareconf
```

If you need more memory for Java, use the following R line **before** loading a package performing a JVM initialization.
```R
options( java.parameters = "-Xmx4g" )
```



## Example
See the `ChoR/inst/examples/script.R` for some examples.
The Rgraphviz package from bioconductor is needed to plot the obtained graphs.
```R
source("https://bioconductor.org/biocLite.R")
biocLite("Rgraphviz")
library(Rgraphviz)
```



## ARFF data
If you need to work with ARFF data, use the RWeka package:
```R
library(RWeka)
myARFFdata = read.arff("/path/to/myfile.arff")
```



## Submission to CRAN and documentation on package development
* https://cran.r-project.org/web/packages/policies.html
* https://cran.r-project.org/doc/manuals/r-release/R-exts.html
* "For Java .class and .jar files, the sources should be in a top-level java directory in the source package
  (or that directory should explain how they can be obtained)."
