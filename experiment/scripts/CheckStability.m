function [stability_check] = CheckStability(v)

    [~,X] = hist(v);
    stability_check = abs(max(X)/min(X));


end