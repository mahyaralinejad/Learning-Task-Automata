function P = calcProdMC(P_chain, D, L)
    % L is label function encoded as table/array: [2,6,7,...]
    % i.e. state 1 has label 2, state 2 has label 6, state 3 has label 7 etc.
    s_states = size(P_chain, 1);
    q_states = size(D, 1);
    %disp("q_states")
    %disp(q_states)
    n_prods = s_states*q_states;
    P = zeros(n_prods, n_prods);
    for i=1:s_states
        for j=1:s_states
            for q=1:q_states
                for q_=1:q_states
%                     disp(P((q-1)*s_states + i, (q_-1)*s_states + j))
%                     disp(P_chain(i,j))
%                     disp(D(q,q_,L(j)))
                    P((q-1)*s_states + i, (q_-1)*s_states + j) = P_chain(i,j)*D(q,q_,L(j));
                end
            end
        end
    end

end