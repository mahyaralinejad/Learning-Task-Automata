%% Case Study
% Clear environment
%clear;

n_seed = sum(100 * clock);
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', n_seed))

%% Setup environment and true dynamics
% 1 = nothing
% 2 = coffee
% 3 = bug
% 4 = beer
% 5 = lemon
% 6 = stairs
% 7 = bomb

list = [
    [1,1,1];
    [1,2,2];
    [1,1,3];
    [1,1,4];
    [1,1,5];
    [1,1,6];
    %[1,1,7];
    [2,2,1];
    [2,2,2];
    [2,2,3];
    [2,2,4];
    [2,2,5];
    [2,3,6];
    %[2,2,7];
    [3,3,1];
    [3,3,2];
    [3,3,3];
    [3,3,4];
    [3,3,5];
    [3,3,6];
    %[3,3,7]
    ];

P_chain = zeros(25,25);

for s1=1:5
    for s2=1:5
        if s1 ~= 5
            P_chain(grid_coord(s1,s2,5), grid_coord(s1+1,s2,5)) = 0.25;
        else
            P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) = P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) + 0.25;
        end
        if s2 ~= 5
            P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2+1,5)) = 0.25;
        else
            P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) = P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) + 0.25;
        end
        if s1 ~= 1
            P_chain(grid_coord(s1,s2,5), grid_coord(s1-1,s2,5)) = 0.25;
        else
            P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) = P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) + 0.25;
        end
        if s2 ~= 1
            P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2-1,5)) = 0.25;
        else
            P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) = P_chain(grid_coord(s1,s2,5), grid_coord(s1,s2,5)) + 0.25;
        end
    end
end

% modify for bomb sink state
%P_chain(grid_coord(3,3,5),:) = zeros(1,25);
% self-loops to itself only
%P_chain(grid_coord(3,3,5),grid_coord(3,3,5)) = 1;

L = ones(1,25);
labels = [ 
    1,5,2;
    % 2,5,2;
    3,1,4; % couch
    %3,3,7;
    3,5,3; % tv
    4,4,5;
    4,5,5;
    5,2,4; % couch
    5,3,6; % stairs
    5,4,5;
    5,5,5
    ];

for i=1:size(labels, 1)
    L(grid_coord(labels(i,1), labels(i,2), 5)) = labels(i,3); 
end

P = calcProdMC(P_chain, DFA(list), L);

MC_states = size(P_chain,1);
DFA_states = max([max(list(:,1)), max(list(:,2))]);

% Kronecker product creates below structure
n_accept_states = 1;
% I = eye(7);
% kron_arg = zeros(MC_states, 7);
% for i=1:MC_states
%     kron_arg(i,:) = I(L(i),:);
% end
E_true = kron( [ones(DFA_states-n_accept_states, 1) , zeros(DFA_states-n_accept_states, 1); 0, 1] , eye(MC_states));%kron_arg );

%% Learning algorithm setup
DFA_state_bound_guess = 3;
n_guess_accept_states = 1;
% no. hidden states
n = MC_states*DFA_state_bound_guess;

% Initialise random stochastic matrix
T_est = rand(n);
T_est = T_est./sum(T_est, 2);

% E_initial = E_true;%kron( [ones(DFA_states-n_accept_states, 1) , zeros(DFA_states-n_accept_states, 1); 0, 1] , eye(7));
E_est = E_true;
%% Run test:
tic
% Choose amount of training data to generate and learn from:
% Number of sequences
sequences = 10000;
% Length of each episode
len = 138; % 85 = 25\% 138 = 50\% 215 = 75\%

% prodL = kron( ones(1, DFA_state_bound_guess), L );
% reward_prodL = prodL;
% reward_prodL(MC_states*(DFA_state_bound_guess - 1):MC_states*DFA_state_bound_guess) = prodL(MC_states*(DFA_state_bound_guess - 1):MC_states*DFA_state_bound_guess) + max(L);

observationSequences = zeros(sequences, len); 
count = 1;
while count <= sequences
    % hmmgenerate always begins in the first state
%     if count > len/2
%         seq = hmmgenerate(len, P, E_true);
%     else
%         seq = gen_seq(len, P, prodL, reward_prodL);
%     end
    seq = hmmgenerate(len, P, E_true);
    observationSequences(count,:) = seq;
    count = count + 1;
end

wins = observationSequences > 25;
win_rate = sum(wins(:,len))/sequences
% run local:
% [T_est, E_est] = hmmtrain(observationSequences, T_est, E_initial);%'Maxiterations', 1000);
% save("bomb_output")
% timeVal = toc
for i=1:100
    [T_est, E_est] = hmmtrain(observationSequences, T_est, E_est, 'Tolerance', 1e-6, 'Maxiterations',10,'Verbose',true)
    save("case_study_"+string(round(n_seed)))
    timeVal = toc
end