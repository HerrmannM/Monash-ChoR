# Warning: RJava requires to **copy** your data from R into a JVM.
# If you need extra memory, use this option (here, for 4Gb) **before** loading choR.
# Note: not needed in our case, kept for the example
options( java.parameters = "-Xmx4g" )
library(ChoR)

## Test JAVA version
jv <- rJava::.jcall("java/lang/System", "S", "getProperty", "java.runtime.version")
jvn <- as.numeric(paste0(strsplit(jv, "[.]")[[1L]][1:2], collapse = "."))
if(jvn < 1.8){ stop("Java 8 is needed for this package but not available") }

# Helper function for graph printing. Require Rgraphviz:
# source("https://bioconductor.org/biocLite.R")
# biocLite("Rgraphviz")
printGraph = function(x){
  if(requireNamespace("Rgraphviz", quietly=TRUE)){
    attrs <- list(node=list(shape="ellipse", fixedsize=FALSE, fontsize=25))
    Rgraphviz::plot(x, attrs=attrs)
  } else { stop("Rgraphviz required for graph printing.") }
}


###### MUSHROOM #####
# We read the data from internet: http://repository.seasr.org/Datasets/UCI/csv/mushroom.csv
MR.data =
  read.csv(  "http://repository.seasr.org/Datasets/UCI/csv/mushroom.csv",
              header            = TRUE,             # Here, we have a header
              na.strings        = c("NA","?",""),   # Configure the missing values
              stringsAsFactors  = FALSE,            # Keep strings for now
              check.names       = TRUE              # Replace some special characters
            )

# This file has a special line with types. You can check this with MR.data[1,].
# Let's remove it:
MR.data = MR.data[-1, ]

# Launch the SMT analysis, with:
# ## default pValueThreshold=0.05
# ## computation of attributes cardinality from the data
MR.res = ChoR.SMT(MR.data)

# Access the result:
# ## As a list of cliques:
NR.cl = ChoR.as.cliques(MR.res)
print(NR.cl)
# ## As a formula
NR.fo = ChoR.as.formula(MR.res)
print(NR.fo)
# ## As a graph
if(requireNamespace("graph", quietly=TRUE)){
  NR.gr = ChoR.as.graph(MR.res)
  printGraph(NR.gr)
} else {
  print("'graph' package not installed; Skipping 'as graph' example.")
}



###### Titanic #####
T.data =
  read.csv( "https://ww2.amstat.org/publications/jse/datasets/titanic.dat.txt",
            sep               = "",       # White spaces
            header            = FALSE,
            stringsAsFactors  = FALSE
          )

# Give meaningful names
colnames(T.data) = c(   "Class", "Age", "Sex", "Survived" )
# Chordalysis
T.res = ChoR.SMT(T.data, card = c(4, 2, 2, 2))

if(requireNamespace("graph", quietly=TRUE)){
  T.gr = ChoR.as.graph(T.res)
  printGraph(T.gr)
}



####### Solar flare #####
#SF.data =
#  read.csv( # "https://archive.ics.uci.edu/ml/machine-learning-databases/solar-flare/flare.data2",
#            "https://raw.githubusercontent.com/jeffheaton/proben1/master/flare/flare.data2",
#            sep               = "",       # White spaces
#            skip              = 1,
#            header            = FALSE,
#            stringsAsFactors  = FALSE,
#            check.names       = TRUE
#          )
#
## Remove last 3 columns (classes, not attributes)
#SF.data = SF.data[-11:-13]
## Give meaningful names
#colnames(SF.data) = c(  "ClassCode", "LSpotSizeCode", "DistCode", "Activity",
#                        "Evolution", "PrevActivity", "HistoricallyComplex", "BecomeComplex",
#                        "Area", "AreaLSpot")
## Chordalysis
#SF.res = ChoR.SMT(SF.data, card = c(7, 6, 4, 2, 3, 3, 2, 2, 2, 2))
#
#if(requireNamespace("graph", quietly=TRUE)){
#  SF.gr = ChoR.as.graph(SF.res)
#  printGraph(SF.gr)
#}
#
