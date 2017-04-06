dir_train = 'speechdata/Training/'

DD = dir(dir_train);
num_speakers = length(DD) - 2;
phns = struct;
for i = 3:length(DD)
  speaker_dir = DD(i);
  path = strcat(dir_train,'/',speaker_dir.name,'/');
  phnFiles = dir(fullfile(strcat(path,'*.phn'))) ;
  for j = 1:length(phnFiles);
      phnFile = strcat(path, phnFiles(j).name);
     mfccFilename = strrep(phnFile, 'phn', 'mfcc');
     phnData = importdata(phnFile, ' ');
     mfccData = dlmread(mfccFilename);
     for k = 1:size(phnData)
        line =  textscan(phnData{k},'%d %d %s');
        if line{1} == 0
            start = 1;
        else
            start = (line{1} + 1)/128;
        end
        mfccSize = size(mfccData, 1);
        endIdx = min(mfccSize, (line{2} + 1)/128);
        phnSequence = mfccData(start:endIdx, :);
      
        if strcmp(line{3}, 'h#')
            phone = 'sil';
        else
            phone = line{3}{1};
        end
        if isfield(phns, phone)
            seqNum = size(phns.(phone), 2) + 1;
            phns.(phone){1, seqNum} = phnSequence';
        else
            [phns(:).(phone)]=deal(cell(1,1));
            phns.(phone){1} = phnSequence';
        end
        
     end
  end
end

fields = fieldnames(phns);

%iterate through phones
phnsHMMs = phns;
for i=1:numel(fields)
  fields{i}
  data = phns.(fields{i});
  HMM = initHMM(data);
  HMM = trainHMM(HMM, data, 10);
  phnsHMMs.(fields{i}) = HMM;
end