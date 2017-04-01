function [ output_args ] = write_to_lik( i, top_5)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    format = '%s\t%f\n' ;
    file = fopen(strcat('unkn_', int2str(i), '.lik'), 'w');
    [r,c] = size(top_5);
    for row = 1:r
       fprintf(file, format, top_5{row, :}); 
    end
    fclose(file);
end

