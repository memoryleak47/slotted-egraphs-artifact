( lambda $A 
   ( lambda $B 
      ( sum $_k_Bk_key $_k_Bk_val 
         ( var $A ) 
         ( sum $_i_Bki_key $_i_Bki_val 
            ( var $_k_Bk_val ) 
            ( sum $_j_Ckj_key $_j_Ckj_val 
               ( get 
                  ( var $B ) 
                  ( var $_k_Bk_key ) 
               ) 
               ( * 
                  ( var $_i_Bki_val ) 
                  ( var $_j_Ckj_val ) 
               ) 
            ) 
         ) 
      ) 
   ) 
)