function [ bmxt ] = calc_bm( x_vec, mu, sigma, d )
% calc observation prob of mth mixture component given covariance matrices
%   x_vec = n -dimensional feature vector
%   mu =  n-dimensional mean vector
%   sigma = n-dimensional vector storing the diag of the covariance matrix
%   d = num of mfcc features
    pi_term = (2*pi)^(d/2);
    sigma_prod_term = sqrt(prod(sigma));
    sum_term = 0;
    for n = 1:d
        sum_term = sum_term + ((x_vec(n)- mu(n))^2)/sigma(n);
    end
    bmxt = exp(-0.5*sum_term)/(pi_term*sigma_prod_term);
    if isnan(bmxt)
        'NAN!'
    end

end

