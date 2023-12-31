function [offer, resp] = simulate_noNorm_1step_ic(free)
    % nRv_fD_cap2_t20_etaf
    
    global offer0
    global n    
    global eta
    
    mn = 1; 
    mx = 9;
    
    envy = free(1);    
    temp = free(2);
    delta = free(3);
   
    offer(1) = offer0;    

    % value function / choice prob
    for i = 1:n       
        
        CV(i) =FS(envy, offer(i), 20 - offer(i) );

       % fprintf('Accept value: %i\r', max(offer(i)-delta, mn) );
       % fprintf('Reject value: %i\r', max(offer(i)+delta, mn) );

        FVa(i) = max(0, FS(envy,  max(offer(i)-delta, mn), 20 - max(offer(i)-delta, mn) ));
        FVr(i) = max(0, FS(envy,  max(offer(i)+delta, mn), 20 - max(offer(i)+delta, mn) ));
        V(i) = CV(i) + eta * ( FVa(i) - FVr(i) );
        
        prob(i) = 1 ./ (1+exp(-temp * V(i)));
        resp(i) = randsample([1, 0], 1, true, [prob(i); 1-prob(i)]);
        
        offer(i+1) = offer_controllable(offer(i), resp(i));                
    end    
    
    offer = offer(1:n); 
end