function [L, pmxt] = computeLikelihood_omega_mu_sigma( mfcc_data, omega, mu, sigma, M, d )
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
           bmxt(m, t) = calc_bm(mfcc_data(t, :), mu_m, sigma_m, d);
        end
    end
    
    for m = 1:M
        omega_m = omega(m);
       for t = 1:num_feat_vecs           
          pmxt(m, t) = omega_m * bmxt(m, t)/sum(diag(omega)*bmxt(:, t));
       end
    end
    L = 0;
    for t = 1:num_feat_vecs
          L = L + log(sum(diag(omega)*bmxt(:,t)));
    end

end
