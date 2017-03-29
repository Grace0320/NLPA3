function data_mat = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture
    
  DD = dir(dir_train);
  num_speakers = length(DD);
  gmms = cell(1, num_speakers);
  
  for i = 3:length(DD)
      speaker_dir = DD(i);
      path = strcat(dir_train, speaker_dir.name,'/');
      gmms(i-2) = {struct('name', speaker_dir.name)};
      mfccFiles = dir(fullfile(strcat(path,'*.mfcc'))) ;
      mfcc_mat = [];
      for j = 1:length(mfccFiles);
          mfcc_mat = [mfcc_mat;dlmread(strcat(path, mfccFiles(j).name))];
      end
      theta = initTheta(mfcc_mat, M);
      j = 0;
      prevL = -Inf ; 
      improvement = inf;
      while j <= max_iter && improvement >= epsilon
          [L, pmxt] = computeLikelihood (mfcc_mat, theta, M);
          theta = updateParams (theta, mfcc_mat, pmxt, M) ;
          improvement = L - prevL;
          prevL = L;
          j = j + 1;
      end
  end
end

function theta = initTheta(mfcc_data, M )
    theta = [];
    omega_init = 1/M;
    omega = cell(M, 1);
    [omega{:}] = deal(omega_init);
    
    num_rows = size(mfcc_data, 1);
    s = RandStream('mt19937ar','Seed',0);
    perm = randperm(s, M, M);
    mu = cell(M, 1);
    for i = 1:M
       [mu(i)] = {deal(mfcc_data(perm(i),:))} ;
    end
    
    sigma_identity = ones(14, M);
    sigma = cell(M, 1);
    [sigma{:}] = deal(sigma_identity);
    theta = horzcat(omega, mu, sigma);
    
end

function [L, pmxt] = computeLikelihood(mfcc_data, theta, M)
    num_feat_vecs = size(mfcc_data, 1);
    bmxt = zeros(M, num_feat_vecs);
    pmxt = zeros(M, num_feat_vecs);
    
    static_bm_term = 7*log(2*pi);
    for m = 1:M % for each gaussian
        mu = theta{m, 2};
        sigma = theta{m, 3};
        
        sigma_prod_term = 0.5 * log(prod(sigma(:, m)));
        no_x_sum_term = 0;
        for n = 1:14
            no_x_sum_term = no_x_sum_term + mu(n)^2/sigma(n,m);
        end
                
        for t = 1:num_feat_vecs %for each vector
           sum_term = 0;
           x_vec = mfcc_data(t, :);
           for n = 1:14 %for each feature
               sum_term = sum_term + (0.5*x_vec(n)^2/sigma(n,m) - mu(n)*x_vec(n)/sigma(n,m));
           end
           
           bmxt(m, t) = -sum_term - (0.5*no_x_sum_term + static_bm_term + sigma_prod_term);
           
        end
    end
    
    for m = 1:M
       omega = theta{m, 1};
       for t = 1:num_feat_vecs
          bm_omega = bmxt(:, t).*[theta{:,1}]';
          denom = sum(bm_omega,1);
          pmxt(m, t) = omega * bmxt(m, t)/denom;
       end
    end
     
    L = sum(log(sum(bsxfun(@times, bmxt, omega))));
end

function newTheta = updateParams(theta, mfcc, pmxt, M)
    newTheta = theta
    num_feat_vecs = size(mfcc, 1);
    sum_vecs_m = sum(pmxt, 2)
    sum_vecs_m(1)
    num2cell(sum_vecs_m./num_feat_vecs)
    newTheta{:,1} = num2cell(sum_vecs_m./num_feat_vecs)
    
    for m = 1:M
        mu =  sum(diag(pmxt(m, :))* mfcc)/sum_vecs_m;
        newTheta{m, 2} = mu;
        newTheta{m, 3} = sum(diag(pmxt(m, :))* (mfcc.^2))./sum_vecs_m - mu.^2
    end
end
