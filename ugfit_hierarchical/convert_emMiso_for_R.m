% Convert to format that is more R-friendly
clear

load('WEIGHTED_FIT_MISO_t20_Oct2_2023.mat')

M.modid     = {'ms_UG2_etaf_f0f_adaptiveNorm'};

expList = fieldnames(s);
for xp = 1:size(fieldnames(s))                
    cur_exp = expList{xp};

    for im = 1:numel(M.modid)
        
       IDs = s.(cur_exp).ID';  
       BIC = s.(cur_exp).em.(M.modid{im}).fit.bic;
       q = s.(cur_exp).em.(M.modid{im}).q;
        
       params = zeros(size(q));
       for i = 1:size(IDs)
            qi = q(i,:);
            params(i,:) = norm2par(M.modid{im},qi);
       end
    
       model_name_save = ['WEIGHTED_FIT_MISO_' cur_exp '_t20_noFlat_' M.modid{im} '_Oct4.csv'];
   
       T= table(IDs,BIC,params);
    
       writetable(T,model_name_save )

    end
end