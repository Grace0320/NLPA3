dir_test = '/h/u1/cs401/speechdata/Testing/'
phnFiles = dir(fullfile(strcat(dir_test,'*.phn'))) ;
phnsTest = struct;
totalPhones = 0;
totalCorrectPhones = 0;
HMMfields = fieldnames(phnsHMMs);
for j = 1:length(phnFiles); %numtests
     phnFile = strcat(dir_test, phnFiles(j).name)
     mfccFilename = strrep(phnFile, 'phn', 'mfcc');
     phnData = importdata(phnFile, ' ');
     mfccData = dlmread(mfccFilename);
     for k = 1:size(phnData)
        totalPhones = totalPhones + 1;
        line =  textscan(phnData{k},'%d %d %s');
        if line{1} == 0
            start = 1;
        else
            start = (line{1} + 1)/128;
        end
        mfccSize = size(mfccData, 1);
        endIdx = min(mfccSize, (line{2} + 1)/128);
        phnSequence = mfccData(start:endIdx, :);
      
        est_phoneme = getLikeliestPhoneme(phnsHMMs, phnSequence');
        
        if strcmp(line{3}{1}, 'h#')
            truePhoneme = 'sil';
        else
            truePhoneme = line{3}{1};
        end
            
        if strcmp(est_phoneme, truePhoneme)
            totalCorrectPhones = totalCorrectPhones + 1;
        end
     end
     correctSoFar = totalCorrectPhones/totalPhones
end
  
correct_percent = totalCorrectPhones/totalPhones * 100