#' Generating A Single Kernel
#'
#' Generate kernels for the kernel library.
#'
#' There are seven kinds of kernel available here. For convenience, we define
#' \eqn{r=\mid x-x'\mid}.
#'
#' \bold{Gaussian RBF Kernels} \deqn{k_{SE}(r)=exp\Big(-\frac{r^2}{2l^2}\Big)}
#'
#' \bold{Matern Kernels}
#' \deqn{k_{Matern}(r)=\frac{2^{1-\nu}}{\Gamma(\nu)}\Big(\frac{\sqrt{2\nu
#' r}}{l}\Big)^\nu K_\nu \Big(\frac{\sqrt{2\nu r}}{l}\Big)}
#'
#' \bold{Rational Quadratic Kernels} \deqn{k_{RQ}(r)=\Big(1+\frac{r^2}{2\alpha
#' l^2}\Big)^{-\alpha}}
#'
#' \bold{Polynomial Kernels} \deqn{k(x, x')=(x \cdot x')^p} We have intercept
#' kernel when \eqn{p=0}, and linear kernel when \eqn{p=1}.
#'
#' \bold{Neural Network Kernels} \deqn{k_{NN}(x,
#' x')=\frac{2}{\pi}sin^{-1}\Big(\frac{2\sigma \tilde{x}^T
#' \tilde{x}'}{\sqrt{(1+2\sigma \tilde{x}^T \tilde{x})(1+2\sigma \tilde{x}'^T
#' \tilde{x}')}}\Big)} where \eqn{\tilde{x}} is the vector \eqn{x} prepending
#' with \eqn{1}.
#'
#' @param method (character) A character string indicating which kernel 
#' is to be computed.
#' @param l (numeric) A numeric number indicating the hyperparameter 
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 / 2; for
#' rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{kern}{(function) A function indicating the generated kernel.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
#' @examples
#'
#' kern_par <- data.frame(method = c("rbf", "polynomial", "matern"),
#' l = c(.5, 1, 1.5), p = 1:3, sigma = rep(1, 3), stringsAsFactors = FALSE)
#' 
#' kern_func_list <- list()
#' for (j in 1:nrow(kern_par)) {
#'   kern_func_list[[j]] <- generate_kernel(kern_par[j, ]$method,
#'                                          kern_par[j, ]$l,
#'                                          kern_par[j, ]$p, 
#'                                          kern_par[j, ]$sigma)
#' }
#'
#'
#' @export generate_kernel
#'
#' @import MASS limSolve stats

generate_kernel <-
  function(method = "rbf", l = 1, p = 2, sigma = 1) {
    method <- match.arg(method, c("intercept", "linear", 
                                  "polynomial", "rbf", 
                                  "matern", "rational", "nn"))
    func_name <- paste0("kernel_", method)
    matrix_wise <- do.call(func_name, list(l = l, p = p, sigma = sigma))
    kern <- function(X1, X2) {
      matrix_wise(X1, X2, l, p, sigma)
    }
    
    kern
  }




#' Generating A Single Matrix-wise Function Using Intercept
#' 
#' Generate matrix-wise functions for two matrices using intercept kernel.
#' 
#' \bold{Polynomial Kernels} \deqn{k(x, x')=(x \cdot x')^p} We have intercept
#' kernel when \eqn{p=0}, and linear kernel when \eqn{p=1}.
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_intercept <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma) {
      matrix(1, nrow = nrow(X1), ncol = nrow(X2))
    }
    matrix_wise
  }




#' Generating A Single Matrix-wise Function Using Linear
#' 
#' Generate matrix-wise functions for two matrices using linear kernel.
#' 
#' \bold{Polynomial Kernels} \deqn{k(x, x')=(x \cdot x')^p} We have intercept
#' kernel when \eqn{p=0}, and linear kernel when \eqn{p=1}.
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_linear <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma) {
      X1 %*% t(X2)
    }
    matrix_wise
  }




#' Generating A Single Matrix-wise Function Using Polynomial
#' 
#' Generate matrix-wise functions for two matrices using polynomial kernel.
#' 
#' \bold{Polynomial Kernels} \deqn{k(x, x')=(x \cdot x')^p} We have intercept
#' kernel when \eqn{p=0}, and linear kernel when \eqn{p=1}.
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_polynomial <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma) {
      (X1 %*% t(X2) + 1) ^ p
    }
    matrix_wise
  }




#' Generating A Single Matrix-wise Function Using RBF
#' 
#' Generate matrix-wise functions for two matrices using rbf kernel.
#' 
#' \bold{Gaussian RBF Kernels} \deqn{k_{SE}(r)=exp\Big(-\frac{r^2}{2l^2}\Big)}
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_rbf <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma) {
      exp(-square_dist(X1, X2, l = sqrt(2) * l))
    }
    matrix_wise
  }




#' Generating A Single Matrix-wise Function Using Matern
#' 
#' Generate matrix-wise functions for two matrices using matern kernel.
#' 
#' \bold{Matern Kernels}
#' \deqn{k_{Matern}(r)=\frac{2^{1-\nu}}{\Gamma(\nu)}\Big(\frac{\sqrt{2\nu
#' r}}{l}\Big)^\nu K_\nu \Big(\frac{\sqrt{2\nu r}}{l}\Big)}
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_matern <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma){
      r <- sqrt(square_dist(X1, X2))
      v <- p + 1 / 2
      s <- 0
      for (i in 0:p) {
        s <- s + factorial(p + i) / (factorial(i) * factorial(p - i)) *
          (sqrt(8 * v) * r / l) ^ (p - i)
      }
      exp(-sqrt(2 * v) * r / l) * gamma(p + 1) / gamma(2 * p + 1) * s
    }
    matrix_wise
  }




#' Generating A Single Matrix-wise Function Using Rational Quadratic
#' 
#' Generate matrix-wise functions for two matrices using rational kernel.
#' 
#' \bold{Rational Quadratic Kernels} \deqn{k_{RQ}(r)=\Big(1+\frac{r^2}{2\alpha
#' l^2}\Big)^{-\alpha}}
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_rational <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma){
      r <- sqrt(square_dist(X1, X2))
      (1 + r ^ 2 / (2 * p * l ^ 2)) ^ (-p)
    }
    matrix_wise
  }




#' Generating A Single Matrix-wise Function Using Neural Network
#' 
#' Generate matrix-wise functions for two matrices using neural network kernel.
#' 
#' \bold{Neural Network Kernels} \deqn{k_{NN}(x,
#' x')=\frac{2}{\pi}sin^{-1}\Big(\frac{2\tilde{x}^T
#' \tilde{x}'}{\sqrt{(1+2\tilde{x}^T \tilde{x})(1+2\tilde{x}'^T
#' \tilde{x}')}}\Big)}
#' 
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @param p (integer) For polynomial, p is the power; for matern, v = p + 1 /
#' 2; for rational, alpha = p.
#' @param sigma (numeric) The covariance coefficient for neural network kernel.
#' @return \item{matrix_wise}{(function) A function calculating the relevance
#' of two matrices.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
kernel_nn <-
  function(l, p, sigma) {
    matrix_wise <- function(X1, X2, l, p, sigma){
      X1 <- cbind(1, X1)
      X2 <- cbind(1, X2)
      X1s <- apply(X1, 1, crossprod)
      X2s <- apply(X2, 1, crossprod)
      X1m <- matrix(X1s, nrow = length(X1s), ncol = nrow(X2), byrow = FALSE)
      X2m <- matrix(X2s, nrow = nrow(X1), ncol = length(X2s), byrow = TRUE)
      s <- 2 * sigma * (X1 %*% t(X2)) / (sqrt((1 + 2 * sigma * X1m) 
                                              * (1 + 2 * sigma * X2m)))
      2 / pi * asin(s)
    }
    matrix_wise
  }




#' Computing Square Distance between Two Sets of Variables
#' 
#' Compute Squared Euclidean distance between two sets of variables with the
#' same dimension.
#' 
#' 
#' @param X1 (matrix, n1*p0) The first set of variables.
#' @param X2 (matrix, n2*p0) The second set of variables.
#' @param l (numeric) A numeric number indicating the hyperparameter
#' (flexibility) of a specific kernel.
#' @return \item{dist_sq}{(matrix, n1*n2) The computed squared Euclidean distance.}
#' @author Wenying Deng
#' @references The MIT Press. Gaussian Processes for Machine Learning, 2006.
#' @keywords internal
#' @export square_dist
square_dist <- function(X1, X2 = NULL, l = 1) {
  X1 <- X1 / l
  X1s <- apply(X1, 1, crossprod)
  if (is.null(X2)) {
    X2 <- X1
    X2s <- X1s
  } else {
    if (ncol(X1) != ncol(X2)) {
      stop("dimensions of X1 and X2 do not match!")
    }
    X2 <- X2 / l
    X2s <- apply(X2, 1, crossprod)
  }
  dist <- -2 * X1 %*% t(X2)
  X1m <- matrix(X1s, nrow = length(X1s), ncol = nrow(X2), byrow = FALSE)
  X2m <- matrix(X2s, nrow = nrow(X1), ncol = length(X2s), byrow = TRUE)
  dist_sq <- dist + X1m + X2m
  dist_sq[which(abs(dist_sq) < 1e-12)] <- 0
  dist_sq
}

