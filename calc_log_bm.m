function bmxt = calc_log_bm( x_vec, mu, sigma )
% calc observation prob of mth mixture component given covariance matrices
%   x_vec = n -dimensional feature vector
%   mu =  n-dimensional mean vector
%   sigma = n-dimensional vector storing the diag of the covariance matri
    static_pi_term = 7*log(2*pi);
    prod_sigma_term = 0.5*log(prod(sigma));
    
    xt_sum_term = 0;
    for n = 1:14
        xt_sum_term = xt_sum_term + (x_vec(n)-mu(n))^2/(2*sigma(n));
    end
    
    bmxt = -xt_sum_term - static_pi_term - prod_sigma_term;
end

