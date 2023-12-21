function [fval, norm, V, choice_prob_arry] = lik_UG3_etaf_f0f_noNorm_2cond(offers, choices, fixed, free, doprior, varargin)
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

            % consider 4 steps (Current and 3 future steps)
            CV(i) = FS(alpha, offer(i), norm(i+1));   % net current value (accept - reject)        
            
            % FV_accept        
            
            ao = max(offer(i)-delta, mn);       % ao = expected offer1 when accept offer0
            
            if FS( alpha, ao, norm(i+1)) > 0                          % a a            
                    aao = max(ao-delta, mn);                
                    if FS( alpha, aao, norm(i+1)) > 0                 % a a a
                        aFV(i) = eta * FS( alpha, ao, norm(i+1)) + eta^2 * FS( alpha, aao, norm(i+1)) ...
                            + eta^3 * max(FS( alpha, max(aao-delta, mn), norm(i+1)), 0);
                    else                                                            % a a r
                        aFV(i) = eta * FS( alpha, ao, norm(i+1)) + eta^2 * 0 ...
                            + eta^3 * max(FS( alpha, max(aao+delta, mn), norm(i+1)), 0);
                    end
                
            else                                                                 % a r
                    aro = max(ao+delta, mn);                
                    if FS( alpha, aro, norm(i+1)) > 0                 % a r a
                        aFV(i) = eta * 0 + eta^2 * FS( alpha, aro, norm(i+1)) ...
                            + eta^3 * max(FS( alpha, max(aro-delta, mn), norm(i+1)), 0);
                    else                                                            % a r r
                        aFV(i) = eta * 0 + eta^2 * 0 ...
                            + eta^3 * max(FS( alpha, max(aro+delta, mn), norm(i+1)), 0);
                    end
            end
            
            
            % FV_reject
            
            ro = max(offer(i)+delta, mn);       % ro = expected offer1 when reject offer0
            
            if FS( alpha, ro, norm(i+1)) > 0                          % r a            
                    rao = max(ro-delta, mn);                
                    if FS( alpha, rao, norm(i+1)) > 0                 % r a a
                        rFV(i) = eta * FS( alpha, ro, norm(i+1)) + eta^2 * FS( alpha, rao, norm(i+1)) ...
                            + eta^3 * max(FS( alpha, max(rao-delta, mn), norm(i+1)), 0);
                    else                                                            % r a r
                        rFV(i) = eta * FS( alpha, ro, norm(i+1)) + eta^2 * 0 ...
                            + eta^3 * max(FS( alpha, max(rao+delta, mn), norm(i+1)), 0);
                    end
                
            else                                                                 % r r
                    rro = max(ao+delta, mn);                
                    if FS( alpha, rro, norm(i+1)) > 0                 % r r a
                        rFV(i) = eta * 0 + eta^2 * FS( alpha, rro, norm(i+1)) ...
                            + eta^3 * max(FS( alpha, max(rro-delta, mn), norm(i+1)), 0);
                    else                                                            % r r r
                        rFV(i) = eta * 0 + eta^2 * 0 ...
                            + eta^3 * max(FS( alpha, max(rro+delta, mn), norm(i+1)), 0);
                    end
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