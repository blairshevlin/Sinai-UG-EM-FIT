function [fval, norm, V, choice_prob_arry] = lik_UG1_etaf_f0f_noNorm_2cond(offers, choices, fixed, free, doprior, varargin)
   if nargin > 5
        prior      = varargin{1};
        q = varargin{2};
    end

    mn = 1;
    mx = 9;    

    eta = fixed(1);
    f0 = fixed(2);

    [alpha, beta, delta_IC, delta_NC] = deal(free{:});

    conds = {'IC','NC'};

    choice_prob_arry = [];
%%
    for c = 1:length(conds)

        offer = offers{c};
        resp = choices{c};

        n = length(offer);

        % initialize norm
        norm(1) = f0;

        % Which delta to use
        if c == 1
            delta = delta_IC;
        else
            delta = delta_NC;
        end

        for i = 1:n  

            %nom update
            norm(i+1) = 20 - offer(i);

            % consider 2 steps (current and 1 future)
            CV(i) = FS(alpha, offer(i), norm(i+1));   % net current value (accept - reject)        
            
            FVa(i) = max(0, FS(alpha,  max(offer(i)-delta, mn), norm(i+1)));
            FVr(i) = max(0, FS(alpha,  max(offer(i)+delta, mn), norm(i+1)));
            V(i) = CV(i) + eta * ( FVa(i) - FVr(i) );     
        end 

        % calculate probability of accepting offer:                                                                                             
        prob     = 1 ./ ( 1 + exp(-beta.*V));  
    
        % find when offer was actually choosen:
        accept = find(resp == 1);
        reject = find(resp == 0);
    
        ChoiceProb(accept) = prob(accept);
        ChoiceProb(reject) = 1 - prob(reject);

        % Put choice probabilities in an array
        choice_prob_arry = [choice_prob_arry, ChoiceProb];

    end

    %%
   
    nll =-nansum(log(choice_prob_arry));  % the thing to minimize                  
    
    if doprior == 0                % NLL fit
       fval = nll;
    elseif doprior == 1             % EM-fit:   P(Choices | h) * P(h | O) should be maximised, therefore same as minimizing it with negative sign   
       fval = -(-nll + prior.logpdf(q));
       if isinf(fval)
           fval = 10000000;
           return
       end
    end
    
    if sum(isnan(choice_prob_arry))>0, disp('ERROR'); keyboard; return; end   % error check  

end