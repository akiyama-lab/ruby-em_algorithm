# Ruby EM Algorithm

EM Algorithm calculation library for Ruby.

## Getting Started

### Installation

    % gem install ruby-em_algorithm

### Tips

To install gsl in Mac OS X, you can use MacPorts. However, currently gsl for ruby 1.14.7 has several errors with gsl 1.15 installed by MacPorts. You can remove errors by editing following two files and comment out two function declaration.

    % sudo vi /opt/local/include/gsl/gsl_matrix_complex_double.h
    /* int gsl_matrix_complex_equal (const gsl_matrix_complex * a, const gsl_matrix_complex * b); */

    % sudo vi /opt/local/include/gsl/gsl_vector_complex_double.h
    /* int gsl_vector_complex_equal (const gsl_vector_complex * u, 
                                    const gsl_vector_complex * v); */

After editing those two files, you can install gsl as follows:

    % gem install gsl

### Examples

You can find examples in example directory.

    ### 1 dimentional EM/GMM estimation example
    % ./example/tools/boxmuller.rb > ./example/data/gmm-test.txt
    % ./example/ex1.rb ./example/data/gmm-test.txt

    ### 2 dimentional EM/GMM estimation example
    % ./example/tools/2dim.rb without_weight > ./example/data/2dim-gmm-without_weight-test.txt
    % ./example/ex2.rb ./example/data/2dim-gmm-without_weight-test.txt

    ### 2 dimentional EM/GMM estimation example with observation weight
    % ./example/tools/2dim.rb > ./example/data/2dim-gmm-test.txt
    % ./example/ex3.rb ./example/data/2dim-gmm-test.txt

## License (MIT License)

ruby-em_algorithm is released under the MIT license.
