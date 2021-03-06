setup_kernel_lib <- function() {
  kern_par <- data.frame(
    method = c("rbf", "polynomial", "matern"),
    l = c(.5, 1, 1.5),
    p = 1:3,
    stringsAsFactors = FALSE
  )
  
  # set up kernel library
  kern_func_list <- define_library(kern_par)
  kern_func_list
}

# helper function for computing kernel matrix
compute_expected_matrix <- function(term_names, kern_func, 
                                    data, data_new = NULL) {
  data_mat <- as.matrix(data[, term_names, drop = FALSE])
  
  data_mat_new <- data_mat
  if (!is.null(data_new)){
    data_mat_new <- as.matrix(data_new[, term_names, drop = FALSE])
  }
  
  kern_func(data_mat_new, data_mat)
}

