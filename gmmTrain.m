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
  
  d = 14;
  
  for i = 3:length(DD)
      speaker_dir = DD(i);
      path = strcat(dir_train,'/',speaker_dir.name,'/');
      speaker_struct = struct('name', speaker_dir.name);
      mfccFiles = dir(fullfile(strcat(path,'*.mfcc'))) ;
      mfcc_mat = [];
      for j = 1:length(mfccFiles);
         mfcc_mat = [mfcc_mat;dlmread(strcat(path, mfccFiles(j).name))];
     end
     theta = initTheta(mfcc_mat, M, d);
      j = 0;
      prevL = -Inf ; 
      improvement = inf;
      while j <= max_iter && improvement >= epsilon
          [L, pmxt] = computeLikelihood_fulltheta (mfcc_mat, theta, M, d);
          theta = updateParams (theta, mfcc_mat, pmxt, M) ;
          improvement = L - prevL;
          prevL = L;
          j = j + 1;
      end
      [speaker_struct(:).weights]=deal([theta{:,1}]);
      [speaker_struct(:).means] = cell2mat(theta(:,2));
      [speaker_struct(:).cov] = cell2mat(theta(:,3));
      gmms(i-2) = {speaker_struct};
  end
  save( 'gmms.mat', 'gmms', '-mat'); 
end

function theta = initTheta(mfcc_data, M, d )
    theta = [];
    omega_init = 1/M;
    omega = cell(M, 1);
    [omega{:}] = deal(omega_init);
    
    num_rows = size(mfcc_data, 1);
    s = RandStream('mt19937ar','Seed',0);
    perm = randperm(s,num_rows, M);
    mu = cell(M, 1);
    for i = 1:M
       [mu(i)] = {deal(mfcc_data(perm(i),:))} ;
    end
    
    sigma_identity = ones(1, d);
    sigma = cell(M, 1);
    [sigma{:}] = deal(sigma_identity);
    theta = horzcat(omega, mu, sigma);
    
end

function newTheta = updateParams(theta, mfcc, pmxt, M)
    newTheta = theta;
    num_feat_vecs = size(mfcc, 1);
    sum_vecs_m = sum(pmxt, 2);
    newTheta(:,1) = deal(num2cell(sum_vecs_m./num_feat_vecs));
    
    for m = 1:M
        mu = sum(diag(pmxt(m, :))*mfcc)/sum_vecs_m(m);
        newTheta{m, 2} = mu;
        sigma = sum(diag(pmxt(m, :)*(mfcc.^2)))/sum_vecs_m(m) - mu.^2;
        newTheta{m, 3} = sigma;
    end
end
