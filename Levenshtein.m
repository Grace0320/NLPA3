function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

    txtFiles = dir(fullfile(strcat(annotation_dir,'unkn_*.txt'))) ;
    hypoText = importdata(hypothesis);
    txtFormat = '%d %d %s';
    total_del = 0;
    total_sub = 0;
    total_ins = 0;
    total_refwords = 0;
    up = 1;
    left = 2;
    upleft = 3;
    for k = 1:length(hypoText); %numtests
        hypoLine = regexp(hypoText{k}, ' ', 'split');
        hypoLine = hypoLine(:, 3:end);
        refFile  = importdata( strcat(annotation_dir,'unkn_',num2str(k), '.txt'));
        refLine = regexp(refFile{1}, ' ', 'split');
        refLine = refLine(:, 3:end);
        numHypoWords = size(hypoLine, 2);
        numRefWords = size(refLine, 2);
        total_refwords = total_refwords + numRefWords;
        
        R = zeros(numRefWords + 1, numHypoWords + 1);
        B = zeros(numRefWords + 1, numHypoWords + 1);
        for i = 1:numRefWords + 1
           R(i, 1) = i - 1; 
        end
        for j = 1:numHypoWords + 1
           R(1, j) = j - 1; 
        end
        
        R(1,1) = 0;
        
        for i = 2:numRefWords + 1
           for j = 2:numHypoWords + 1
              del = R(i-1, j) + 1;
              sub = R(i-1, j-1) + ~strcmp(refLine{i-1}, hypoLine{j-1});
              ins = R(i, j - 1) + 1;
              
              R(i, j) = min([del, sub, ins]);
              if R(i,j) == del
                  B(i,j) = up;
              elseif R(i,j) == ins
                  B(i, j ) = left;
              else
                  B(i, j) = upleft;
              end
           end
        end
        
        i = numRefWords + 1;
        j = numHypoWords + 1;
        while i > 1 && j > 1
            bij = B(i, j);
            if bij == up
                total_del = total_del + 1;
                i =  i - 1;
            elseif bij == left
                total_ins = total_ins + 1;
                j = j - 1;
            else
                if ~strcmp(refLine{i-1},hypoLine{j-1})
                    total_sub = total_sub + 1;
                end
                
                i = i - 1;
                j = j - 1;
            end
                    
        end
    end
    total_sub
    total_del
    total_ins 
    
    total_refwords
    SE = total_sub/total_refwords;
    IE = total_ins/total_refwords;
    DE = total_del/total_refwords;
    LEV_DIST = SE + IE + DE;
end