#' Isotonic distributional regression (IDR)
#' 
#' Isotonic distributional Regression (IDR) is a nonparametric method to 
#' estimate conditional distributions under monotonicity constraints.
#' 
#' @section How does it work?:
#' 
#' Read the arXiv preprint `Isotonic Distributional Regression' on 
#' \url{https://arxiv.org/abs/1909.03725} or by calling 
#' \code{browseVignettes(package = "isodistrreg")}. 
#' 
#' @section The \pkg{isodistrreg} package:
#' 
#' To make probabilistic forecasts with IDR,
#' \itemize{
#' \item call \code{\link{idr}(y = y, X = X, ...)}, where \code{y} is the
#'   response variable (e.g. weather variable observations) and \code{X} is a
#'   \code{data.frame} of covariates (e.g. ensemble forecasts).
#' \item use \code{\link[=predict.idrfit]{predict}(fit, data)}, where \code{fit}
#'   is the model fit computed with \code{idr} and \code{data} is the data based
#'   on which you want to make predictions.
#' \item Try \code{\link{idrbag}} for IDR with (su)bagging.
#' }
#' The following pre-defined functions are available to evaluate IDR
#' predictions:
#' \itemize{
#' \item \code{\link{cdf}} and \code{\link{qpred}} to compute the cumulative
#' distribution function (CDF) and quantile function of IDR predictions.
#' \item \code{\link{bscore}} and \code{\link{qscore}} to calculate Brier scores
#'   for probability forecasts for threshold exceedance (e.g. probability of
#'   precipitation) and quantile scores (e.g. mean absolute error of median
#'   forecast.)
#' \item \code{\link{crps}} to compute the continuous ranked probability score
#' (CRPS).
#' \item \code{\link{pit}} to compute the probability integral transform (PIT).
#' \item \code{\link[=plot.idr]{plot}} to plot IDR predictive CDFs.
#' }
#' Use the dataset \code{\link{rain}} to test IDR.
#' 
#' @docType package
#' @name isodistrreg-package
#' 
#' @useDynLib isodistrreg, .registration = TRUE
#' 
#' @references 
#' 
#' Alexander Henzi, Johanna F. Ziegel, and Tilmann Gneiting. Isotonic
#' Distributional Regression. arXiv e-prints, art. arXiv:1909.03725, Sep 2019.
#' URL \url{https://arxiv.org/abs/1909.03725}.
#' 
#' @examples 
#' 
#' \donttest{
#' ## A usage example:
#' 
#' # Prepare dataset: Half of the data as training dataset, other half for validation.
#' # Consult the R documentation (?rain) for details about the dataset.
#' data(rain)
#' trainingData <- subset(rain, date <= "2012-01-09")
#' validationData <- subset(rain, date > "2012-01-09")
#' 
#' # Variable selection: use HRES and the perturbed forecasts P1, ..., P50
#' varNames <- c("HRES", paste0("P", 1:50))
#' 
#' # Partial orders on variable groups: Usual order of numbers on HRES (group '1') and
#' # increasing convex order on the remaining variables (group '2').
#' groups <- setNames(c(1, rep(2, 50)), varNames)
#' orders <- c("comp" = 1, "icx" = 2)
#' 
#' # Fit IDR to training dataset.
#' fit <- idr(
#'   y = trainingData[["obs"]],
#'   X = trainingData[, varNames],
#'   groups = groups,
#'   orders = orders
#' )
#' 
#' # Make prediction for the first day in the validation data:
#' firstPrediction <- predict(fit, data = validationData[1, varNames])
#' plot(firstPrediction)
#' 
#' # Use cdf() and qpred() to make probability and quantile forecasts:
#' 
#' ## What is the probability of precipitation?
#' 1 - cdf(firstPrediction, thresholds = 0)
#' 
#' ## What are the predicted 10%, 50% and 90% quantiles for precipitation?
#' qpred(firstPrediction, quantiles = c(0.1, 0.5, 0.9))
#' 
#' # Make predictions for the complete verification dataset and compare IDR calibrated
#' # forecasts to the raw ensemble (ENS):
#' predictions <- predict(fit, data = validationData[, varNames])
#' y <- validationData[["obs"]]
#' 
#' ## Continuous ranked probability score (CRPS):
#' CRPS <- cbind(
#'   "ens" = crps(validationData[, varNames], y),
#'   "IDR" = crps(predictions, y)
#' )
#' apply(CRPS, 2, mean)
#' 
#' ## Brier score for probability of precipitation:
#' BS <- cbind(
#'   "ens" = bscore(validationData[, varNames], thresholds = 0, y),
#'   "IDR" = bscore(predictions, thresholds = 0, y)
#' )
#' apply(BS, 2, mean)
#' 
#' ## Quantile score of forecast for 90% quantile:
#' QS90 <- cbind(
#'   "ens" = qscore(validationData[, varNames], quantiles = 0.9, y),
#'   "IDR" = qscore(predictions, quantiles = 0.9, y)
#' )
#' apply(QS90, 2, mean)
#' 
#' ## Check calibration using (randomized) PIT histograms:
#' pitEns <- pit(validationData[, varNames], y)
#' pitIdr <- pit(predictions, y)
#' 
#' hist(pitEns, main = "PIT of raw ensemble forecasts", freq = FALSE)
#' hist(pitIdr, main = "PIT of IDR calibrated forecasts", freq = FALSE)
#' }
NULL

#' Unload dll when package is unloaded
#' 
#' @return 
#' No return value, called for side effects.
#' 
#' @keywords internal
.onUnload <- function (libpath) {
  library.dynam.unload("isodistrreg", libpath)
}