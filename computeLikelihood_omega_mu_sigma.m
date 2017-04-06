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

%https://www.mathworks.com/matlabcentral/fileexchange/26184-em-algorithm-for-gaussian-mixture-model--em-gmm-?focused=6047117&tab=function
function s = logsumexp(X, dim, omega)
    % Compute log(sum(exp(X),dim)) while avoiding numerical underflow.
    %   By default dim = 1 (columns).
    % Written by Mo Chen (sth4nth@gmail.com).
    if nargin == 1, 
        % Determine which dimension sum will use
        dim = find(size(X)~=1,1);
        if isempty(dim), dim = 1; end
    end

    % subtract the largest in each dim
    y = max(X,[],dim);
    s = y+log(sum(diag(omega)*exp(bsxfun(@minus,X,y)),dim)) ;  % TODO: use log1p
    i = isinf(y);
    if any(i(:))
        s(i) = y(i);
    end
end