( lambda A 
   ( lambda A1 
      ( lambda A2 
         ( lambda B 
            ( lambda B1 
               ( lambda B2 
                  ( sum _i_Bi_key _i_Bi_val 
                     ( sum _rr_r_key _rr_r_val 
                        ( range 
                           1 
                           ( var A1 ) 
                        ) 
                        ( sing 
                           ( unique 
                              ( var _rr_r_val ) 
                           ) 
                           ( sum _cc_c_key _cc_c_val 
                              ( range 
                                 1 
                                 ( var A2 ) 
                              ) 
                              ( sing 
                                 ( unique 
                                    ( var _cc_c_val ) 
                                 ) 
                                 ( get 
                                    ( var A ) 
                                    ( + 
                                       ( * 
                                          ( - 
                                             ( var _rr_r_val ) 
                                             1 
                                          ) 
                                          ( var A2 ) 
                                       ) 
                                       ( var _cc_c_val ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                        ) 
                     ) 
                     ( sing 
                        ( var _i_Bi_key ) 
                        ( sum _j_Cj_key _j_Cj_val 
                           ( sum _rr_r_key _rr_r_val 
                              ( range 
                                 1 
                                 ( var B1 ) 
                              ) 
                              ( sing 
                                 ( unique 
                                    ( var _rr_r_val ) 
                                 ) 
                                 ( sum _cc_c_key _cc_c_val 
                                    ( range 
                                       1 
                                       ( var B2 ) 
                                    ) 
                                    ( sing 
                                       ( unique 
                                          ( var _cc_c_val ) 
                                       ) 
                                       ( get 
                                          ( var B ) 
                                          ( + 
                                             ( * 
                                                ( - 
                                                   ( var _rr_r_val ) 
                                                   1 
                                                ) 
                                                ( var B2 ) 
                                             ) 
                                             ( var _cc_c_val ) 
                                          ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                           ( sing 
                              ( var _j_Cj_key ) 
                              ( sum _k_Bik_key _k_Bik_val 
                                 ( var _i_Bi_val ) 
                                 ( * 
                                    ( var _k_Bik_val ) 
                                    ( get 
                                       ( var _j_Cj_val ) 
                                       ( var _k_Bik_key ) 
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
)
