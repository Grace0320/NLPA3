
load('gmms.mat')
mfccFiles = dir(fullfile(strcat('speechdata/Testing/','*.mfcc'))) ;

num_tests = size(mfccFiles, 1);

for i = 1:numtests
   
    save(strcat('unkn_', i, '.lik'));
end