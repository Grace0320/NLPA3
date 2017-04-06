function [accuracy, top5_accuracy] = classify( dir_test, mfccFiles, d, gmm, num_speakers, num_test_files, gmm_name, answers)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    total_correct = 0;
    total_top5_correct = 0;
    for i = 1:num_test_files
       mfcc_mat = dlmread(strcat(dir_test, mfccFiles(i).name));
       top_5 = [];  %format [speakername, prob; speakername2, prob2;...]
       for s = 1:num_speakers
           speaker_theta = gmm{1,s}; 
           omega = speaker_theta.weights;
           mu = speaker_theta.means;
           sigma = speaker_theta.cov;
           M = size(omega, 2);

           [L, pmxt] = computeLikelihood_omega_mu_sigma(mfcc_mat, omega, mu, sigma, M, d);
           top_5 = vertcat(top_5, {speaker_theta.name, L});

           if size(top_5, 1) > 5
              tmp = sortrows(top_5, 2);
              top_5 = tmp(1:5, :);
           end
       end
       if i <= 15
           if top_5{1} == answers(i, :)
               total_correct = total_correct + 1;
           end
           if strmatch(answers(i, :), top_5(:, 1))
               total_top5_correct = total_top5_correct + 1;
           end
       end
       write_to_lik(i, gmm_name, top_5);
    end
    accuracy = total_correct/15;
    top5_accuracy = total_top5_correct/15;
end

