function [V] = FS_unbound(envy, offer, norm)

    V = offer - envy * (norm - offer);
    
end