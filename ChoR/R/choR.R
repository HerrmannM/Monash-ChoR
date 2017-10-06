########################################################################################################################
### INTERNAL - TOOLING
########################################################################################################################

#' @title [INTERNAL] Load the data from a dataframe (and with an optionnal cardinality vector)
#'
#' @description Loads the data from x, which should be a dataframe (else, a conversion to a dataframe is attempted).
#'
#' @details
#' Loads the data from x, which should be a dataframe (else, a conversion to a dataframe is attempted).
#' The data must be categorical, each column being an attribute. The optionnal argument card should
#' be a vector representing the cardinality of each attribute (position wise).
#' If it is provided, its size must be equal to the number of attributes.
#' Else, its values will be computed from the data, and the cardinality for an attribute will be accurate only
#' if all its possible values appear at least once in the data.
#'
#' @param x A dataframe with categorical data; column names are the name of the attributes.
#' @param card A vectore containing the cardinality of the attributes (position wise).
#' @return A list how two .jarray references (one for the dimension, one for the data) and the dataframe
ChoR.loadData <- function(x, card=NULL){

  # --- 1: Check for missing values and format
  if(any(is.na(x))){
    warning("missing values in 'x', treated as a possible value.")
  }

  if(!(is.data.frame(x) | is.matrix(x))) {
    warning("data not provided as data.frame or matrix, converting to data.frame")
    x <- as.data.frame(x)
  }

  # --- 2: convert to factor to ensure categorical data through level (converted in int), include missing values
  intData <- matrix(as.integer(0), nrow=nrow(x), ncol=ncol(x))
  for(i in 1:ncol(x)) {
    intData[,i] <- as.integer(factor(x[,i], exclude = NULL)) - 1L # !!! Indice correction: java works on [0, n-1]
  }

  # --- 3: If no description of cardiable cardinality, guess them from the data,
  #       else, apply correction for missing values and ensure that the dimensions match
  if(is.null(card)) {
    card <- apply(intData, 2, max) + 1 # 2 == column wise, + 1 to reverse the index correction [0, n-1] -> [1, n]
  } else {
    card <- as.integer(as.vector((card)))
    # Check length
    if(length(card) != ncol(x)) { stop("Cardinality vector and dataframe dimension mismatch.")  }
    # Apply correction for missing values: increase cardinality of attribute
    missings = which(apply(x, 2, anyNA))
    for(i in missings){ card[i] = card[i]+1 }
  }

  # --- 4: Load the data in jarrays
  javacard    <- rJava::.jarray(as.integer(card))           # Create a 1D int array
  javaIntData <- rJava::.jarray(intData, dispatch=TRUE )    # Create a 2D int array thanks to dispatch
  return ( list(javacard, javaIntData, x) )
}



#' @title [INTERNAL] Process the result of a java Chordalysis algorithm.
#'
#' @description Convert the result in a 'chordalysis object'.
#'
#' @details
#' Process the result of a call to the java Chordalysis algorithm.
#' The result is a String of the forme "~0*1*2+...+3*4*5".
#' The numbers (+1 for indice correction) are replaced with the corresponding column name in x,
#' and the string is split in a list of cliques, a cliques being a list of name.
#' For example, "~ 0*1*2 + 3*4*5" gives the two cliques [[ [[0,1,2]], [[3,4,5]] ]]
#'
#' @param x The dataframe used to loadData; column names are the name of the attributes.
#' @param modelStr The result of a java Chordalysis algorithm
#' @return A Chordalysis object. Use \code{ChoR.as.*} functions to access the result.
ChoR.processResult <- function(x, modelStr){

  # --- 1: Transform the result: model is a string of the forme "~0*1*2+...+3*4*5"
  # remove ~ and split first on '+' and then on '*'
  model <- substr(modelStr, 2, nchar(modelStr))
  model <- strsplit(strsplit(model,"\\+")[[1]], "\\*")
  # replace number by attributes name taken from the dataframe.
  model <- lapply(model, function(y) { colnames(x)[as.integer(y)+1]  })

  # --- 5: S3 model: result is a list, with class "chordalysis"
  res <- list()
  res[["model"]] <- model
  res[["modelStr"]] <- toString(res)
  class(res) <- "chordalysis"

  return(res)
}



########################################################################################################################
### PUBLIC - EXPLORER
########################################################################################################################



#' @title Call to the MML chordalysis algorithm.
#'
#' @description Searches a statistically significant decomposable model to explain a dataset.
#'
#' @details
#' Call the MML chordalysis function on the dataframe x. The optionnal card argument can provide a vector
#' of cardinalities for each attribute (i.e. column) of the dataframe. If absent, the cardinalities are computed
#' from the dataframe, but may not be accurate if some possible values never show up. See papers
#' "A statistically efficient and scalable method for log-linear analysis of high-dimensional data, ICDM 2014"
#' and "Scaling log-linear analysis to datasets with thousands of variables, SDM 2015" for more details.
#'
#' @param x A dataframe with categorical data; column names are the name of the attributes.
#' @param card A vector containing the cardinality of the attributes (position wise).
#' @return A Chordalysis object. Use \code{ChoR.as.*} functions to access the result.
#' @export
#' @examples
#' \dontrun{ res = ChoR.MML(data) }
#' \dontrun{ res = ChoR.MML(data, c(3, 5, 4, 4, 3, 2, 3, 3)) }
ChoR.MML <- function(x, card=NULL){
  # --- 1: Load the data
  arrays    <- ChoR.loadData(x, card)
  # --- 2: Call Chordalysis
  modelStr  <- rJava::.jcall("choR/ChoR", "S", "ChordalysisModellingMML", arrays[[1]], arrays[[2]])
  # --- 3: Process the result. WARNING: use the datafrale fril ChoR.loadData (could have been converted)
  return ( ChoR.processResult(arrays[[3]], modelStr) )
}



#' @title Call to the SMT chordalysis algorithm.
#'
#' @description Searches a statistically significant decomposable model to explain a dataset using Prioritized Chordalysis.
#'
#' @details
#' Call the SMT chordalysis function on the dataframe x. The optionnal card argument can provide a vector
#' of cardinalities for each attribute (i.e. column) of the dataframe. If absent, the cardinalities are computed
#' from the dataframe, but may not be accurate if some possible values never show up. See papers
#' "A multiple test correction for streams and cascades of statistical hypothesis tests, KDD 2016",
#' "Scaling log-linear analysis to high-dimensional data, ICDM 2013", and
#' "Scaling log-linear analysis to datasets with thousands of variables, SDM 2015" for more details.
#'
#' @param x A dataframe with categorical data; column names are the name of the attributes.
#' @param pValueThreshold A double value, minimum p-value for statistical consistency (commonly 0.05)
#' @param card A vector containing the cardinality of the attributes (position wise).
#' @return A Chordalysis object. Use \code{ChoR.as.*} functions to access the result.
#' @examples
#' \dontrun{ res = ChoR.SMT(data, 0.05, c(3, 5, 4, 4, 3, 2, 3, 3)) }
#' \dontrun{ res = ChoR.SMT(data, card = c(3, 5, 4, 4, 3, 2, 3, 3)) }
#' @export
ChoR.SMT <- function(x, pValueThreshold=0.05, card=NULL){
  # --- 1: Load the data
  arrays    <- ChoR.loadData(x, card)
  # --- 2: Call Chordalysis
  modelStr  <- rJava::.jcall("choR/ChoR", "S", "ChordalysisModellingSMT", arrays[[1]], arrays[[2]], pValueThreshold)
  # --- 3: Process the result. WARNING: use the datafrale fril ChoR.loadData (could have been converted)
  return ( ChoR.processResult(arrays[[3]], modelStr) )
}



#' @title Call to the budget chordalysis algorithm.
#'
#' @description Searches a statistically significant decomposable model to explain a dataset using Prioritized Chordalysis. 
#'
#' @details
#' Call the Budget chordalysis function on the dataframe x. The optionnal card argument can provide a vector
#' of cardinalities for each attribute (i.e. column) of the dataframe. If absent, the cardinalities are computed
#' from the dataframe, but not accurate if some possible values never show up. See papers
#' "Scaling log-linear analysis to high-dimensional data, ICDM 2013",
#' "Scaling log-linear analysis to datasets with thousands of variables, SDM 2015", and
#' "A multiple test correction for streams and cascades of statistical hypothesis tests, KDD 2016" for more details.
#'
#' @param x A dataframe with categorical data; column names are the name of the attributes.
#' @param pValueThreshold A double value, minimum p-value for statistical consistency (commonly 0.05)
#' @param budgetShare A double value, share of the statistical budget to consume at each step (>0 and <=1; 0.01 seems like a reasonable value for most datasets)
#' @param card A vector containing the cardinality of the attributes (position wise).
#' @return A Chordalysis object. Use \code{ChoR.as.*} functions to access the result.
#' @export
#' @examples
#' \dontrun{ res = ChoR.Budget(data) }
#' \dontrun{ res = ChoR.Budget(data, budgetShare=0.0) }
#' \dontrun{ res = ChoR.Budget(data, 0.05, card = c(3, 5, 4, 4, 3, 2, 3, 3)) }
ChoR.Budget <- function(x, pValueThreshold=0.05, budgetShare=0.01, card=NULL){
  # --- 0: Pre check for range
  if( budgetShare<0 | budgetShare>=1 ){ stop("budgetShare must be in ]0, 1]") }
  # --- 1: Load the data
  arrays    <- ChoR.loadData(x, card)
  # --- 2: Call Chordalysis
  modelStr  <- rJava::.jcall("choR/ChoR", "S", "ChordalysisModellingBudget", arrays[[1]], arrays[[2]], pValueThreshold, budgetShare)
  # --- 3: Process the result. WARNING: use the dataframe from ChoR.loadData (could have been converted)
  return ( ChoR.processResult(arrays[[3]], modelStr) )
}



########################################################################################################################
### PUBLIC - QUERY THE RESULT
########################################################################################################################



#' @title Get the cliques.
#'
#' @description Get the list of cliques associated to a chordalysis object.
#'
#' @param x A chordalysis object obtained by a call to ChoR.
#' @return A list of cliques, a clique being a list of attributes'name, i.e. a list of lists of names.
#' @export
ChoR.as.cliques <- function(x){
  # --- 1: Sanity check
  if(!inherits(x,"chordalysis")){ stop ("not a chordalysis object") }
  # --- 2: Return the list of cliques
  return ( x$model )
}



#' @title Get the formula.
#'
#' @description Extract the formula from a Chordalysis object.
#'
#' @param x A chordalysis object obtained by a call to ChoR.
#' @return a formula representing the model
#' @export
ChoR.as.formula <- function(x){
  # --- 1: Sanity check
  if(!inherits(x,"chordalysis")){ stop ("not a chordalysis object") }
  # --- 2: Extract the formula
  return(stats::as.formula(x$modelStr))
}



#' @title Get the graph.
#'
#' @description Get an undirected graph representing the cliques from a Chordalysis object.
#'
#' @details
#' The undirected graph use the graph package from Bioconductor.
#'
#' @param x A chordalysis object obtained by a call to ChoR.
#' @return A graph
#' @export
ChoR.as.graph <- function(x){
  # Check if the package is available
  if(requireNamespace("graph", quietly=TRUE)){
    # Graph Node Edge List, start only with the nodes
    nodes = unique(unlist(x$model))
    g = graph::graphNEL(nodes)
    # Loop on the model in order to add the edges:
    for(clique in x$model){
      top = length(clique)
      if(top!=1){ # Fails if we only have one item in the clique!
        for(i in 1:(top-1)){
          for(j in (i+1):top){
            g = graph::addEdge( clique[[i]], clique[[j]], g, 1)
          }
        }
      }
    }
    # Return the graph
    return(g)
  } else {
    stop("ChoR.as.graph requires the graph package from Bioconductor. Please install it.", call. = FALSE)
  }
}



#' @title Gives a string representation of the model.
#'
#' @description
#' Create a String representation of a model, compatible with the formula interface,
#' e.g. "~a*b*c+...+e*f*g".
#'
#' @param x A "Chordalysis" model, obtained by a call to a ChoR function.
#' @param ... Unused argument, here for S3 consistency
#' @return A String representation of the model.
#' @export
print.chordalysis <- function(x, ...) {
  # --- 1: Sanity check
  if(!inherits(x,"chordalysis")){ stop ("not a chordalysis object") }
  # --- 2: Transform the list of list in a formula string "~a*b*c+...+e*f*g"
  res <- toString(x)
  # --- 3: Print it and 'invisible retun' it
  print(res)
  invisible(res)
}



########################################################################################################################
### INTERNAL - TOOLING FOR QUERIES
########################################################################################################################



#' @title [INTERNAL] Gives a string representation of the model.
#'
#' @description
#' Create a String representation of a model, compatible with the formula interface,
#' e.g. "~a*b*c+...+e*f*g".
#'
#' @param x A "Chordalysis" model, obtained by a call to a ChoR function.
#' @return A String representation of the model.
toString <- function(x) {
  res <- paste(lapply(x$model, function(y) {paste(y, collapse="*")}), collapse="+")
  res <- paste0('~', res)
  return(res)
}
