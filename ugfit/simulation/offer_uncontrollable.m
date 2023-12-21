function [offer_sequence] = offer_uncontrollable(n)

    if n == 30
            offers = [ones(1,2) 2*ones(1,3) 3*ones(1,3) 4*ones(1,4) 5*ones(1,5) ...
            6*ones(1,4) 7*ones(1,3) 8*ones(1,3) 9*ones(1,2)];
            offers = Shuffle(offers);
    elseif n == 40
       offers = [ones(1,3) 2*ones(1,4) 3*ones(1,5) 4*ones(1,5) 5*ones(1,6) ...
        6*ones(1,5) 7*ones(1,4) 8*ones(1,4) 9*ones(1,3)];

    end
    
    offer_sequence = [5 offers];    
    
end