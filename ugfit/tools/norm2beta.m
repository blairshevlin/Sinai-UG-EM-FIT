function [ beta_out ] = norm2beta(beta)
% transformation from gaussian space to alpha space, as suggested in Daw 2009 Tutorial
% MKW October 2017
% Edited by SR & BRKS 2023
beta_out = exp(beta); 

%beta_out = 10 / (1 + exp(-beta));

end

