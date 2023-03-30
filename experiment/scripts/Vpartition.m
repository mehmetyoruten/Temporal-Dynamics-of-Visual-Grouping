function [v_partition] = Vpartition(W,D,v)
%VPARTITION Get the eigenvector, and generate vector x with categorical
%values of -1 and 1.



v_median = median(v);
l_list = (v_median - 0.1):0.01:(v_median+0.1);

v_partition_list = ones(length(v), length(l_list));

nCut_scores = NaN(1,length(l_list));

for i=1:length(l_list)
    v_partition = ones(length(v),1);

    l = l_list(i);
    
    v_partition(v <= l) = -1;
    v_partition_list(:,i) = v_partition;
    
    nCut_scores(i) = NcutValue(W,D,v_partition);
end

[~, idx] = sort(nCut_scores);
v_partition = v_partition_list(:,idx(1));

v_partition = sign(v);

end
