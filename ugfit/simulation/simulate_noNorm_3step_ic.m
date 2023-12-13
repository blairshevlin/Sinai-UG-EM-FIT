function [offer, resp] = simulate_noNorm_3step_ic(free)
% nRv_f4_cap2_t20_etaf

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
        
        CV(i) = FS(envy, offer(i), 20 - offer(i) );   % net current value (accept - reject)        
        
        
        % FV_accept        
        
        ao = max(offer(i)-delta, mn);       % ao = expected offer1 when accept offer0
        
        if FS(envy, ao, 20 - ao) > 0                          % a a            
                aao = max(ao-delta, mn);                
                if FS(envy, aao, 20 - aao) > 0                 % a a a
                    aFV(i) = eta * FS(envy, ao, 20 - ao) + eta^2 * FS(envy, aao, 20 - aao) ...
                        + eta^3 * max(FS(envy, max(aao-delta, mn), 20 - max(aao-delta, mn) ), 0);
                else                                                            % a a r
                    aFV(i) = eta * FS(envy, ao, 20 - ao) + eta^2 * 0 ...
                        + eta^3 * max(FS(envy, max(aao+delta, mn), 20 - max(aao+delta, mn)), 0);
                end
            
        else                                                                 % a r
                aro = max(ao+delta, mn);                
                if FS(envy, aro, 20 - aro) > 0                 % a r a
                    aFV(i) = eta * 0 + eta^2 * FS(envy, aro, 20 - aro) ...
                        + eta^3 * max(FS(envy, max(aro-delta, mn), 20 -  max(aro-delta, mn)), 0);
                else                                                            % a r r
                    aFV(i) = eta * 0 + eta^2 * 0 ...
                        + eta^3 * max(FS(envy, max(aro+delta, mn), 20 - max(aro+delta, mn)), 0);
                end
        end
        
        
        % FV_reject
        
        ro = max(offer(i)+delta, mn);       % ro = expected offer1 when reject offer0
        
        if FS(envy, ro, 20 - ro) > 0                          % r a            
                rao = max(ro-delta, mn);                
                if FS(envy, rao, norm(i+1)) > 0                 % r a a
                    rFV(i) = eta * FS(envy, ro, 20 - ro) + eta^2 * FS(envy, rao, 20 - rao) ...
                        + eta^3 * max(FS(envy, max(rao-delta, mn), 20 - max(rao-delta, mn) ), 0);
                else                                                            % r a r
                    rFV(i) = eta * FS(envy, ro, 20 - ro) + eta^2 * 0 ...
                        + eta^3 * max(FS(envy, max(rao+delta, mn), 20 - max(rao+delta, mn)), 0);
                end
            
        else                                                                 % r r
                rro = max(ao+delta, mn);                
                if FS(envy, rro, 20 - rro) > 0                 % r r a
                    rFV(i) = eta * 0 + eta^2 * FS(envy, rro, 20 - rro) ...
                        + eta^3 * max(FS(envy, max(rro-delta, mn), 20 - max(rro-delta, mn)), 0);
                else                                                            % r r r
                    rFV(i) = eta * 0 + eta^2 * 0 ...
                        + eta^3 * max(FS(envy, max(rro+delta, mn), 20 - max(rro+delta, mn)), 0);
                end
        end
                                            
                
        V(i) = CV(i) + (aFV(i) - rFV(i));
                
        prob(i) = 1 ./ (1+exp(-temp * V(i)));
        resp(i) = randsample([1, 0], 1, true, [prob(i); 1-prob(i)]);       
        
        offer(i+1) = offer_controllable(offer(i), resp(i));                
    end    
    
    offer = offer(1:n);    
end