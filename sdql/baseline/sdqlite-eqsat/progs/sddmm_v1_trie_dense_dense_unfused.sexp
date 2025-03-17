( lambda A 
   ( lambda B 
      ( lambda B1 
         ( lambda B2 
            ( lambda C 
               ( lambda C1 
                  ( lambda C2 
                     ( sum _i_Bi_key _i_Bi_val 
                        ( var A ) 
                        ( sing 
                           ( var _i_Bi_key ) 
                           ( sum _j_Bij_key _j_Bij_val 
                              ( var _i_Bi_val ) 
                              ( sing 
                                 ( var _j_Bij_key ) 
                                 ( let Dj 
                                    ( get 
                                       ( sum _cc_c_key _cc_c_val 
                                          ( range 
                                             1 
                                             ( var C2 ) 
                                          ) 
                                          ( sing 
                                             ( unique 
                                                ( var _cc_c_val ) 
                                             ) 
                                             ( sum _rr_r_key _rr_r_val 
                                                ( range 
                                                   1 
                                                   ( var C1 ) 
                                                ) 
                                                ( sing 
                                                   ( unique 
                                                      ( var _rr_r_val ) 
                                                   ) 
                                                   ( get 
                                                      ( var C ) 
                                                      ( + 
                                                         ( * 
                                                            ( - 
                                                               ( var _cc_c_val ) 
                                                               1 
                                                            ) 
                                                            ( var C1 ) 
                                                         ) 
                                                         ( var _rr_r_val ) 
                                                      ) 
                                                   ) 
                                                ) 
                                             ) 
                                          ) 
                                       ) 
                                       ( var _j_Bij_key ) 
                                    ) 
                                    ( * 
                                       ( var _j_Bij_val ) 
                                       ( sum _k_Cik_key _k_Cik_val 
                                          ( get 
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
                                             ( var _i_Bi_key ) 
                                          ) 
                                          ( * 
                                             ( var _k_Cik_val ) 
                                             ( get 
                                                ( var Dj ) 
                                                ( var _k_Cik_key ) 
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
      ) 
   ) 
)
