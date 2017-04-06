function  likeliestPhoneme = getLikeliestPhoneme( phnsHMMs, data )
%Iterate through HMMs to find most likely phone
%   phnsHMMs - struct with fieldnames = phonemes, values = HMMs

    phones = fieldnames(phnsHMMs);
    highestL = -Inf;
    for i = 1:numel(phones)
        L = loglikHMM(phnsHMMs.(phones{i}), data);
        if likelihood > highestL
            likeliestPhoneme = phones{i};
            highestL = likelihood;
        end
    end
end

