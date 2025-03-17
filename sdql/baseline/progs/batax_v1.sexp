( lambda B 
   ( lambda C 
      ( lambda D 
         ( sum _ii_Aj_key _ii_Aj_val 
            ( var C ) 
            ( sum _j_a_val_key _j_a_val_val 
               ( var _ii_Aj_val ) 
               ( sing 
                  ( var _j_a_val_key ) 
                  ( * 
                     ( * 
                        ( var B ) 
                        ( var _j_a_val_val ) 
                     ) 
                     ( sum _k_a2_val_key _k_a2_val_val 
                        ( var _ii_Aj_val ) 
                        ( * 
                           ( var _k_a2_val_val ) 
                           ( get 
                              ( var D ) 
                              ( var _k_a2_val_key ) 
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
