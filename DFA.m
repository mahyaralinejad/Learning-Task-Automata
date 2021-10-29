function D = DFA(list)
    % Assume list is cell structure
    % list will be defined as [ [q,q',1]; ... }
    n_transitions = size(list, 1);
    n_alph = max(list(:,3));
    n_q = max([max(list(:,1)), max(list(:,2))]);
    D = zeros(n_q, n_q, n_alph);
    for r=1:n_transitions
        D(list(r,1),list(r,2),list(r,3)) = 1;
    end
end