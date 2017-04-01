function [L, pmxt] = computeLikelihood_fulltheta(mfcc_data, theta, M)
% given parameter set theta, compute likelihood of mfcc_data vector set
%
    omega = [theta{:,1}];
    mu = cell2mat(theta(:,2));
    sigma = cell2mat(theta(:,3));
    [L, pmxt] = computeLikelihood_omega_mu_sigma(mfcc_data, omega, mu, sigma, M);
    
end
