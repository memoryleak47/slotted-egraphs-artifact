( lambda $A 
   ( lambda $B 
      ( sum $_i_Bi_key $_i_Bi_val 
         ( var $A ) 
         ( sum $_k_Bik_key $_k_Bik_val 
            ( var $_i_Bi_val ) 
            ( sum $_j_Ckj_key $_j_Ckj_val 
               ( get 
                  ( var $B ) 
                  ( var $_k_Bik_key ) 
               ) 
               ( sing 
                  ( var $_i_Bi_key ) 
                  ( sing 
                     ( var $_j_Ckj_key ) 
                     ( * 
                        ( var $_k_Bik_val ) 
                        ( var $_j_Ckj_val ) 
                     ) 
                  ) 
               ) 
            ) 
         ) 
      ) 
   ) 
)