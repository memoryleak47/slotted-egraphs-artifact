( lambda B 
   ( lambda C1 
      ( lambda C2 
         ( lambda C3 
            ( lambda D 
               ( lambda D1 
                  ( * 
                     ( var B ) 
                     ( sum _i_Aj_key _i_Aj_val 
                        ( sum _i_p_key _i_p_val 
                           ( var C1 ) 
                           ( let q 
                              ( get 
                                 ( var C1 ) 
                                 ( + 
                                    ( var _i_p_key ) 
                                    1 
                                 ) 
                              ) 
                              ( sing 
                                 ( var _i_p_key ) 
                                 ( sum _r_j_key _r_j_val 
                                    ( subarray 
                                       ( var C2 ) 
                                       ( var _i_p_val ) 
                                       ( - 
                                          ( var q ) 
                                          1 
                                       ) 
                                    ) 
                                    ( sing 
                                       ( unique 
                                          ( var _r_j_val ) 
                                       ) 
                                       ( get 
                                          ( var C3 ) 
                                          ( var _r_j_key ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                        ) 
                        ( * 
                           ( var _i_Aj_val ) 
                           ( sum _j_a_val_key _j_a_val_val 
                              ( var _i_Aj_val ) 
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
                        ) 
                     ) 
                  ) 
               ) 
            ) 
         ) 
      ) 
   ) 
)