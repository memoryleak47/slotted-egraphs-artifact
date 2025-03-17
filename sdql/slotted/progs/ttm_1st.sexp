( lambda $A 
   ( lambda $B 
      ( sum $_i_Bi_key $_i_Bi_val 
         ( var $B ) 
         ( sum $_j_Bij_key $_j_Bij_val 
            ( var $_i_Bi_val ) 
            ( sum $_k_Ck_key $_k_Ck_val 
               ( var $A ) 
               ( sum $_l_B_v_key $_l_B_v_val 
                  ( var $_j_Bij_val ) 
                  ( sing 
                     ( var $_i_Bi_key ) 
                     ( sing 
                        ( var $_j_Bij_key ) 
                        ( sing 
                           ( var $_k_Ck_key ) 
                           ( * 
                              ( var $_l_B_v_val ) 
                              ( get 
                                 ( var $_k_Ck_val ) 
                                 ( var $_l_B_v_key ) 
                              ) 
                           ) 
                        ) 
                     ) 
                  ) 
               ) 
            ) 
         ) 
      ) 
   ) 
)