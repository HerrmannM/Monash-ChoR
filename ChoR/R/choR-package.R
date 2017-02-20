#############################################################################
#
#   This file is part of the R package "ChoR".
#
#   Author: Matthieu Herrmann
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Library General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Library General Public License for more details.
#
#   You should have received a copy of the GNU Library General Public License
#   along with this library; see the file COPYING.LIB.  If not, write to
#   the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
#############################################################################

#' @title Getting started with the ChoR package
#'
#' @description
#' The chordalysis algorithm allows to learn the structure of graphical models from datasets with thousands of variables.
#' More information about the research papers detailing the theory behind Chordalysis is available at
#' \url{http://www.francois-petitjean.com/Research}
#'
#' If you have problems using ChoR, find a bug, or have suggestions, please
#' contact the package maintainer by email.
#' Do not write to the general R lists or contact the authors of the original chordalysis software.
#'
#' If you use the package, please cite references in your publications.
#'
#' @details
#' Chordalysis allows to learn the structure of graphical models from datasets with thousands of variables.
#' There are 3 differentes algorithms versions: SMT, Budget and MML. SMT, standing for Subfamiliwize Multiple Testing,
#' is generally the method of choice. It superseeds Budget and is always superior to it. Demonstration is in our KDD'16 paper (see CITATION). Both SMT and Budget
#' are based on statistical testing, while MML uses information theory to decide upon a model. The objective of the different techniques is slightly different: SMT controls the familywise 
#' error rate (FWER) while MML is a probabilistic method. Our experiments (again in KDD'16) indicate that SMT is superior to MML 
#' for most datasets.
#'
#' @docType package
#' @name ChoR
#' @keywords package model linear-log-analysis
#' @references See citation("ChoR")
#' @title Getting started with the ChoR package
#' @example inst/examples/script.R

NULL
