function [L, pmxt] = computeLikelihood_omega_mu_sigma( mfcc_data, omega, mu, sigma, M )
%given parameter set omega, mu, sigma, compute likelihood of mfcc_data
%vector set with M gaussian mixtures
%   
    num_feat_vecs = size(mfcc_data, 1);
    bmxt = zeros(M, num_feat_vecs);
    pmxt = zeros(M, num_feat_vecs);
    for m = 1:M % for each gaussian
        mu_m = mu(m, :);
        sigma_m = sigma(m, :);
        for t = 1:num_feat_vecs %for each vector
           bmxt(m, t) = calc_log_bm(mfcc_data(t, :), mu_m, sigma_m);
        end
    end
    
    for m = 1:M
       omega_m = omega(m);
       for t = 1:num_feat_vecs
          bm_omega = bmxt(:, t).*omega';
          denom = sum(bm_omega,1);
          pmxt(m, t) = omega_m * bmxt(m, t)/denom;
       end
    end
    L = sum(sum(diag(omega)*bmxt));

end

