\name{compare_plot}
\alias{compare_plot}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
This function compare rates of values within an output factor grouped by the values of a testing feature. It returns a summary table of rates of the output feature grouped by the input feature and plots these results. Beware the default output "abroad" is not present in the raw data "train_users_2". Run The first chunk of "exploration.Rmd" to get this. 
}
\usage{
compare_plot(feature = NA, df = train_users_2,
output = "abroad", seperate = FALSE, plot = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{feature}{
  Character String. Feature is a factor vector for which we are interested in the rates in which other factors occur when joined. This arugment must match one of the features of df. By default feature is passed as NA, if this remains true...
  }
  \item{df}{
  Character String. Input data, default value is "train_users_2" for the raw kaggle data. Within this data must exist feature and outputs. 
  }
  \item{output}{
  Character String. Output is the factor variable we interested in observing the rate of when grouped by feature. This argument is passed as a string and must 
  
  }
  \item{seperate}{
  Logical. This is unique to using the default output. When TRUE seperates the 3 arguments of abroad into an NDF rate (booking proportion) and EXT rate (external travel). 
  }
  \item{plot}{
  Logical. When False supresses the plotting of the results. 
  }
}

\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
compare_plot(feature = "cyl", df = mtcars, output = "gear")

## The function is currently defined as
function (x) 
{
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
