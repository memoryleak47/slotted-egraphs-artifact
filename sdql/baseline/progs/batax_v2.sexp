( lambda B 
   ( lambda C 
      ( lambda D 
         ( let tmp 
            ( sum _ii_Aj_key _ii_Aj_val 
               ( var C ) 
               ( let alpha 
                  ( sum _j_a_val_key _j_a_val_val 
                     ( var _ii_Aj_val ) 
                     ( * 
                        ( var _j_a_val_val ) 
                        ( get 
                           ( var D ) 
                           ( var _j_a_val_key ) 
                        ) 
                     ) 
                  ) 
                  ( sum _j_a_val_key _j_a_val_val 
                     ( var _ii_Aj_val ) 
                     ( sing 
                        ( var _j_a_val_key ) 
                        ( * 
                           ( var _j_a_val_val ) 
                           ( var alpha ) 
                        ) 
                     ) 
                  ) 
               ) 
            ) 
            ( sum _j_val_key _j_val_val 
               ( var tmp ) 
               ( sing 
                  ( var _j_val_key ) 
                  ( * 
                     ( var B ) 
                     ( var _j_val_val ) 
                  ) 
               ) 
            ) 
         ) 
      ) 
   ) 
)
