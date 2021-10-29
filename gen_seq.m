function Lseq = gen_seq(le, T, L, rewardL)
    % L includes labels AND rewards as part of the labels.
    % So, if there are M possible labels, there will 2*M possible
    % observations -- the first M corresponding to 0 reward, and the second
    % M corresponding to a reward of 1 (in addition to seeing the
    % respective labels). L itself is as along as the number of (product)
    % states in T.

    % We will include two options, first to include sequences generated
    % from an optimal policy, i.e. from an expert teacher, and second to
    % generate transitions sequentially, searching locally (among
    % action/state-transition options) for new labels.
    
    % We implement the second method first because it is simpler and can be
    % used even in contexts where a teacher does not exist.
    
    % This requires maintaining a list of labels seen so far, and a depth 
    % factor controlling how deep to search locally for new labels.
	
    seen = zeros(1, max(L));
    
    % How to grab all labels adjacent to some state in T?
    % Find which states it can transition to, then check those states'
    % labels in E. That is, for the row corresponding to each next-state,
    % check which column it has a 1 in.
    
    seq = zeros(1, le);
    seq(1) = 1;     % 1 is always the initial state by construction
    S = size(T,1);
    for t = 2:le
        next_states_full = T(seq(t-1), :) > 0;
        next_states_full = next_states_full.*[1:S];
        next_states = next_states_full(next_states_full > 0);
        next_labels = L(next_states);
        for i = 1:length(next_labels)
            if seen(next_labels(i)) == 0
                seq(t) = find(next_states_full==next_states(i));
                seen(next_labels(i)) = 1;
                break
            end
        end
        % If no new label is found
        if seq(t) == 0
           % pick random next state
           seq(t) = next_states(randi([1 size(next_states, 2)], 1, 1));
        end
%         seq(t)
%         seen
    end
	Lseq = rewardL(seq);
end