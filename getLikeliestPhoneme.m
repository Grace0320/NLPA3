function  likeliestPhoneme = getLikeliestPhoneme( phnsHMMs, data )
%Iterate through HMMs to find most likely phone
%   phnsHMMs - struct with fieldnames = phonemes, values = HMMs
%   data{i}(d,n) - ith phoneme sequence

    phones = fieldnames(phnsHMMs);
    highestL = -Inf;
    likeliestPhoneme = '';
    for i = 1:numel(phones)
        L = loglikHMM(phnsHMMs.(phones{i}), data);
        if L > highestL
            likeliestPhoneme = phones{i};
            highestL = L;
        end
    end
end

