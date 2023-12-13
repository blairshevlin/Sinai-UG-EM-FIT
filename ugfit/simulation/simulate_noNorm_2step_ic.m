function [offer, resp] = simulate_noNorm_2step_ic(free)
    % nRv_f3_cap2_t20_etaf
    
    global offer0
    global n    
    global eta
    
    mn = 1;  

    envy = free(1);    
    temp = free(2);
    delta = free(3);
   
    offer(1) = offer0;       
   
    % value function / choice prob
    for i = 1:n       
        
        % consider 3 steps
        CV(i) = FS(envy, offer(i), 20 - offer(i) );   % net current value (accept - reject)        
        
        ao = max(offer(i)-delta, mn);
        if FS(envy, ao, 20 - ao) > 0          % if accept(now) & accept(next)
            aFV(i) = eta * FS(envy, ao, 20 - ao) + eta^2 * max(FS(envy, max(ao-delta, mn), 20 - max(ao-delta, mn) ), 0);
        else                                                                 % if accept & reject
            aFV(i) = eta^2 * max(FS(envy, max(ao+delta, mn), 20 -  max(ao+delta, mn) ), 0);
        end
        
        ro = max(offer(i)+delta, mn);
        if FS(envy, ro, 20 - ro) > 0        % reject & accept
            rFV(i) = eta * FS(envy, ro, 20 - ro) + eta^2 * max(FS(envy, max(ro-delta, mn), 20 - max(ro-delta, mn) ), 0);
        else                                                                 % reject & reject
            rFV(i) = eta^2 * max(FS(envy, max(ro+delta, mn), 20 - max(ro+delta, mn)), 0);
        end
                
        V(i) = CV(i) + (aFV(i) - rFV(i));
        
        prob(i) = 1 ./ (1+exp(-temp * V(i)));
        resp(i) = randsample([1, 0], 1, true, [prob(i); 1-prob(i)]);       
        
        offer(i+1) = offer_controllable(offer(i), resp(i));                
    end    
    
    offer = offer(1:n);    
end