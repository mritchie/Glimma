% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{makeDFJson}
\alias{makeDFJson}
\title{Create json from data.frame}
\usage{
makeDFJson(df)
}
\arguments{
\item{df}{A data.frame object}
}
\value{
character string containing data.frame in json format
}
\description{
Create json from data.frame
}
\examples{
data(iris)
makeDFJson(iris)
}

