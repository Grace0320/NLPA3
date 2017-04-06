d = 14;
test_truth = importdata('speechdata/Testing/TestingIDs1-15.txt');
test_answers_mat = [];
for i = 2:size(test_truth)
    answer = textscan(string(test_truth{i}),'%d : %s');
    speaker = answer{2};
    speaker = speaker{1}(1:end-1);
    test_answers_mat = vertcat(test_answers_mat, [speaker]);
end
%train various models
% gmm_m_10 = gmmTrain('speechData/Training/', 100, 0, 10);
% gmm_m_20 = gmmTrain('speechData/Training/', 100, 0, 20);
% gmm_m_30 = gmmTrain('speechData/Training/', 100, 0, 30);
% 
% gmm_ep_1 = gmmTrain('speechData/Training/', 100, 1, 5);
% gmm_ep_10 = gmmTrain('speechData/Training/',100, 10, 5);
% gmm_ep_100 = gmmTrain('speechData/Training/', 100, 100, 5);
% gmm_ep_1000 = gmmTrain('speechData/Training/', 100, 1000, 5);
% 
% gmm_missing_last_speakers = gmm_m_20(1:15);

mfccFiles = dir(fullfile(strcat('speechdata/Testing/','*.mfcc'))) ;
num_tests = size(mfccFiles, 1);
num_speakers = size(gmm_m_10, 2);

dir_test = 'speechdata/Testing/';
%classify( dir_test, mfccFiles, d, gmm, num_speakers, num_test_files, gmm_name)
% [acc_m10, top5_m10] = classify(dir_test, mfccFiles, d, gmm_m_10, num_speakers, num_tests, 'm10', test_answers_mat);
% 'm10 done'
% [acc_m20, top5_m20] = classify(dir_test, mfccFiles, d, gmm_m_20, num_speakers, num_tests, 'm20', test_answers_mat);
% 'm50 done'
% [acc_m30, top5_m30] = classify(dir_test, mfccFiles, d, gmm_m_30, num_speakers, num_tests, 'm30', test_answers_mat);
% 'm100 done'
% [acc_e1, top5_e1] = classify(dir_test, mfccFiles, d, gmm_ep_1, num_speakers, num_tests, 'e1', test_answers_mat);
% 'e1 done'
% [acc_e10, top5_e10] = classify(dir_test, mfccFiles, d, gmm_ep_10, num_speakers, num_tests, 'e10', test_answers_mat);
% 'e10 done'
% [acc_e100, top5_e100] = classify(dir_test, mfccFiles, d, gmm_ep_100, num_speakers, num_tests, 'e100', test_answers_mat);
% 'e100 done'
% [acc_e1000, top5_e1000] = classify(dir_test, mfccFiles, d, gmm_ep_1000, num_speakers, num_tests, 'e1000', test_answers_mat);
% 'e1000 done'
[acc_missing, top5_missing] = classify(dir_test, mfccFiles, d, gmm_missing_last_speakers, 15, num_tests, 'missing', test_answers_mat);