#' Core glimma plot manager. Generates environment for glimma plots.
#' 
#' @param ... the jschart or jslink objects for processing.
#' @param layout the numeric vector representing the number of rows and columns in plot window.
#' @param folder the name of the fold to save html file to.
#' @param html the name of the html file to save plots to.
#' @param overwrite the option to overwrite existing folder if it already exists.
#' @return Generates interactive plots based on filling layout row by row from left to right.
#' @export
#' @examples
#' data(iris)
#' plot1 <- glScatter(iris, xval="Sepal.Length", yval="Sepal.Width", colval="Species")
#' glimma(plot1, c(1,1))
#'

glimma <- function(..., layout=c(1,1), folder="glimma", html="index", overwrite=FALSE) {
	nplots <- 0

	##
	# Input checking
	for (i in list(...)) {
		if (class(i) == "jschart") {
			nplots <- nplots + 1
		}
	}
	
	if (!is.numeric(layout) || !(length(layout) == 2)) {
		stop("layout must be numeric vector of length 2")
	}

	if (layout[2] < 1 || layout[2] > 6) {
		stop("number of columns must be between 1 and 6")
	}

	if (nplots > layout[1] * layout[2]) {
		stop("More plots than available layout cells")
	}

	if (overwrite == FALSE) {
		if (file.exists(folder)) {
			stop(paste(folder, "already exists"))
		}
	}
	#
	##

	# Normalise input
	folder <- ifelse(char(folder, nchar(folder)) == "/" || char(folder, nchar(folder)) == "\\", 
					substring(folder, 1, nchar(folder) - 1),
					folder) # If folder ends with /
	layout <- round(layout)

	# Convert variable arguments into list
	args <- list(...)

	# Create folder
	dir.create(folder)

	# Create file
	index.path <- system.file(package="Glimma", "index.html")
	js.path <- system.file(package="Glimma", "js")
	css.path <- system.file(package="Glimma", "css")
	file.copy(index.path, paste(folder, paste0(html, ".html"), sep="/"))
	file.copy(js.path, folder, recursive=TRUE)
	file.copy(css.path, folder, recursive=TRUE)

	data.path <- paste(folder, "js", "data.js", sep="/")
	cat("", file=data.path, sep="")
	write.data <- writeMaker(data.path)

	actions <- data.frame(from=0, to=0, src="none", dest="none") # Dummy row
	data.list <- list()

	for (i in 1:length(args)) {
		if (class(args[[i]]) == "jslink" || class(args[[i]]) == "jschart") {
			if (args[[i]]$type == "link") {
				actions <- rbind(actions, args[[i]]$link)
			} else if (args[[i]]$type == "scatter") {
			# Write json data
				write.data(paste0("glimma.chartData.push(", args[[i]]$json, ");\n"))

			# Write plot information
				args[[i]]$json <- NULL
				chartInfo <- makeChartJson(args[[i]])
				write.data(paste0("glimma.chartInfo.push(", chartInfo, ");\n"))

			# Write plot call
				constructScatterPlot(args[[i]], i, write.data)
			} else if (args[[i]]$type == "bar") {
			# Write json data
				write.data(paste0("glimma.chartData.push(", args[[i]]$json, ");\n"))

			# Write plot information
				args[[i]]$json <- NULL
				chartInfo <- makeChartJson(args[[i]])
				write.data(paste0("glimma.chartInfo.push(", chartInfo, ");\n"))

			# Write plot call
				constructBarPlot(args[[i]], i, write.data)
			}
		}
	}

	# Write linkage
	if (nrow(actions) > 1) {
		actions.js <- makeDFJson(actions[-1, ])
		write.data(paste0("glimma.linkage = ", actions.js, ";\n"))
	} else {
		write.data("glimma.linkage = [];\n")
	}

	# Generate layout
	layout <- paste0("glimma.layout.setupGrid(d3.select(\".container\"), \"md\", ", "[", layout[1], ",", layout[2], "]);\n")
	write.data(layout)
}