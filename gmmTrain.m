function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
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
  num_speakers = length(DD) - 2;
  gmms = cell(1, num_speakers);
  
  for i = 3:length(DD)
      speaker_dir = DD(i);
      path = strcat(dir_train, speaker_dir.name,'/');
      speaker_struct = struct('name', speaker_dir.name);
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
      
      [speaker_struct(:).weights]=deal([theta{:,1}]);
      [speaker_struct(:).means] = cell2mat(theta(:,2))';
      [speaker_struct(:).cov] = cell2mat(theta(:,3));
      gmms(i-2) = {speaker_struct};
  end
  save( gmms, 'gmms', '-mat'); 
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
    
    sigma_identity = ones(1, 14);
    sigma = cell(M, 1);
    [sigma{:}] = deal(sigma_identity);
    theta = horzcat(omega, mu, sigma);
    
end

function [L, pmxt] = computeLikelihood(mfcc_data, theta, M)
    num_feat_vecs = size(mfcc_data, 1);
    bmxt = zeros(M, num_feat_vecs);
    pmxt = zeros(M, num_feat_vecs);
    
    for m = 1:M % for each gaussian
        mu = theta{m, 2};
        sigma = theta{m, 3};                
        for t = 1:num_feat_vecs %for each vector
           bmxt(m, t) = calc_bm(mfcc_data(t, :), mu, sigma);
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
    newTheta = theta;
    num_feat_vecs = size(mfcc, 1);
    sum_vecs_m = sum(pmxt, 2);
    newTheta(:,1) = deal(num2cell(sum_vecs_m./num_feat_vecs));
    
    for m = 1:M
        mu = sum(diag(pmxt(m, :)/sum_vecs_m(m))* mfcc);
        newTheta{m, 2} = mu;
        newTheta{m, 3} = sum(diag(pmxt(m, :)./sum_vecs_m(m))* (mfcc.^2)) - mu.^2;
    end
end
