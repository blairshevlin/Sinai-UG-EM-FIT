function [fval, norm, V, choice_prob_arry] = lik_UG2_etaf_f0f_adaptiveNorm_2cond(offers, choices, fixed, free, doprior, varargin)
   if nargin > 5
        prior      = varargin{1};
        q = varargin{2};
    end

    mn = 1;
    mx = 9;    

    eta = fixed(1);
    f0 = fixed(2);

    [alpha, beta, epsilon, delta_IC, delta_NC] = deal(free{:});

    conds = {'IC','NC'};

    choice_prob_arry = [];
%%
    for c = 1:length(conds)

        offer = offers{c};
        resp = choices{c};

        n = length(offer);

        % norm update (RW)
        norm = RW(f0, epsilon, offer);

        % Which delta to use
        if c == 1
            delta = delta_IC;
        else
            delta = delta_NC;
        end

        for i = 1:n       
            
            % consider 3 steps
            CV(i) = FS(alpha, offer(i), norm(i+1));   % net current value (accept - reject)        
            
            ao = max(offer(i)-delta, mn);
            if FS(alpha, ao, norm(i+1)) > 0          % if accept(now) & accept(next)
                aFV(i) = eta * FS(alpha, ao, norm(i+1)) + eta^2 * max(FS(alpha, max(ao-delta, mn), norm(i+1)), 0);
            else                                                                 % if accept & reject
                aFV(i) = eta^2 * max(FS(alpha, max(ao+delta, mn), norm(i+1)), 0);
            end
            
            ro = max(offer(i)+delta, mn);
            if FS(alpha, ro, norm(i+1)) > 0        % reject & accept
                rFV(i) = eta * FS(alpha, ro, norm(i+1)) + eta^2 * max(FS(alpha, max(ro-delta, mn), norm(i+1)), 0);
            else                                                                 % reject & reject
                rFV(i) = eta^2 * max(FS(alpha, max(ro+delta, mn), norm(i+1)), 0);
            end
                    
            V(i) = CV(i) + (aFV(i) - rFV(i));       
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