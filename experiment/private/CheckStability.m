function [stability] = CheckStability(v)

    [~,X] = hist(v);
    stability = abs(max(X)/min(X));
    
end