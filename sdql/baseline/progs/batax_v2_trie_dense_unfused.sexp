( lambda B 
   ( lambda C 
      ( lambda D 
         ( lambda D1 
            ( let tmp 
               ( sum _ii_Aj_key _ii_Aj_val 
                  ( var C ) 
                  ( let alpha 
                     ( sum _j_a_val_key _j_a_val_val 
                        ( var _ii_Aj_val ) 
                        ( * 
                           ( var _j_a_val_val ) 
                           ( get 
                              ( sum _rr_r_key _rr_r_val 
                                 ( range 
                                    1 
                                    ( var D1 ) 
                                 ) 
                                 ( sing 
                                    ( unique 
                                       ( var _rr_r_val ) 
                                    ) 
                                    ( get 
                                       ( var D ) 
                                       ( var _rr_r_val ) 
                                    ) 
                                 ) 
                              ) 
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
)
