function bmxt = calc_bm( x_vec, mu, sigma )
% calc observation prob of mth mixture component given covariance matrices
%   x_vec = n -dimensional feature vector
%   mu =  n-dimensional mean vector
%   sigma = n-dimensional vector storing the diag of the covariance matri
    sigma_prod_term = sqrt(prod(sigma))^0.5 *(2*pi)^7;
    sum_term = 0;
    for n = 1:14 %for each feature
        sum_term = sum_term + ((x_vec(n) - mu(n))^2/sigma(n));
	end
    bmxt = exp(-0.5*sum_term)/sigma_prod_term;
end

