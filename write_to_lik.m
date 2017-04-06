function [ output_args ] = write_to_lik( i, name, top_5)
%helper function to write gmmClassify results to file
%   i = test number (unkn_i.mfcc)
%   name = name of gmm
%   top_5 = results of classify, format [NAME1, LOGP1; NAME2, LOGP2;...]

    format = '%s\t%f\n' ;
    file = fopen(strcat('unkn_', int2str(i),'_',name, '.lik'), 'w');
    [r,c] = size(top_5);
    for row = 1:r
       fprintf(file, format, top_5{row, :}); 
    end
    fclose(file);
end

