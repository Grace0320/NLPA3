
load('gmms.mat')
mfccFiles = dir(fullfile(strcat('speechdata/Testing/','*.mfcc'))) ;

num_tests = size(mfccFiles, 1);
num_speakers = size(gmms, 2);

for i = 1:num_tests
   mfcc_mat = dlmread(strcat('speechdata/Testing/', mfccFiles(i).name));
   top_5 = [];  %format [speakername, prob; speakername2, prob2;...]
   for s = 1:num_speakers
       speaker_theta = gmms{1,s}; 
       omega = speaker_theta.weights;
       mu = speaker_theta.means;
       sigma = speaker_theta.cov;
       M = size(omega, 2);
       
       [L, pmxt] = computeLikelihood_omega_mu_sigma(mfcc_mat, omega, mu, sigma, M);
       top_5 = vertcat(top_5, {speaker_theta.name, L});
       
       if size(top_5, 1) > 5
          tmp = sortrows(top_5, 2);
          top_5 = tmp(1:5, :);
       end
   end
   write_to_lik(i, top_5);
end

