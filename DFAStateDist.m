function qDist = DFAStateDist(ProdMC, L, accept_states, sDist)
    % accept_states = array of hidden state indices which are accepting in ProdMC
    
    % L is either the label function if sDist is defined, or the label
    % observation distribution over the hidden states (like sDist
    % but with the labels instead)
    
    % Convert Markov chain matrix into unweighted digraph adjacency matrix
    cutoff = 1e-3;
    ProdMC = ProdMC > cutoff;
    
    dim = length(ProdMC);
    G_MC = digraph(ProdMC);
    
    % Alg.
    % Note, it's better to now assume the number of DFA states is unknown
    
    % 1. Draw hidden states and compare their DFA component, incrementing
    % the number of known distinct DFA states each time a new one is found.
    %   i. If it's not new, then add it to the bin of the hidden state(s)
    %   whose DFA state is equivalent.
    
    % Comparison subroutine: For each pair h and h', compute the symmetric
    % difference of each of their sets of accepting paths. It's empty if and only
    % if the DFA states are equivalent.
    
    qDist = zeros(1, dim);
    
    % Big improvement to reduce the number of these loops is to only loop over
    % hidden states whose DFA states have not been identified
    
    non_accept_states = setdiff(1:dim, accept_states);
    for u = 1:length(non_accept_states)
        for u_ = u+1:length(non_accept_states)
            h  = non_accept_states(u);
            h_ = non_accept_states(u_);
            if qDist(h_) ~= 0
                break
            end
            % sym_diff is equivalent to the set of distinguishing
            % extensions for pairs of strings which lead to the respective
            % DFA states in question
            
            paths1 = {};
            paths2 = {};
            for a = accept_states 
                paths1 = [paths1; allpaths(G_MC, h, a)]; %#ok<*AGROW>
                paths2 = [paths2; allpaths(G_MC, h_, a)];
            end
            % Translate to DFA-alphabet
            for i = 1:size(paths1, 1)
                paths1{i} = L(paths1{i});
            end
            for i = 1:size(paths2, 1)
                paths2{i} = L(paths2{i});
            end
            
            % max path length to accept state
            mlen = 0;
            for i = 1:size(paths1, 1)
                if length(paths1{i}) > mlen
                    mlen = length(paths1{i});
                end
            end
            for i = 1:size(paths2, 1)
                if length(paths2{i}) > mlen
                    mlen = length(paths2{i});
                end
            end
            
            P1 = zeros(size(paths1, 1), mlen);
            P2 = zeros(size(paths2, 1), mlen);
            for i = 1:size(paths1, 1)
                P1(i,1:length(paths1{i})-1) = paths1{i}(2:length(paths1{i}));
            end
            for i = 1:size(paths2, 1)
                P2(i,1:length(paths2{i})-1) = paths2{i}(2:length(paths2{i}));
            end
            h
            h_
            paths1
            paths2
            sym_diff = setxor(P1,P2,'rows')
            pause
            if isempty(sym_diff)
                % DFA states are equivalent
                if qDist(h) == 0
                    % surely if qDist(h)==0, qDist(h_)==0 too because they
                    % are found to have equivalent DFA state. Impossible to
                    % have qDist(h_)==1 in this case.
                    qDist(h) = max(qDist)+1;
                    qDist(h_)= qDist(h);
                else
                    qDist(h_) = qDist(h);                    
                end
            else
                % DFA states are different
                if qDist(h) == 0
                    qDist(h) = max(qDist)+1;             
                    % Sh/Could somehow record the following so that h_ is skipped when
                    % being compared to any state which is known to have same DFA 
                    % state as h: qDist(h_) ~= qDist(h);            
                end
            end  
        end
    end
    qDist(accept_states) = (max(qDist)+1)*ones(1, length(accept_states));
end

% If output distribution had a 0 in the location for some hidden state, it
% means that it's not reachable ?