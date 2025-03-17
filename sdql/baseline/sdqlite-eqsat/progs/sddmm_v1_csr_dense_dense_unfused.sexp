( lambda A1 
   ( lambda A2 
      ( lambda A3 
         ( lambda B 
            ( lambda B1 
               ( lambda B2 
                  ( lambda C 
                     ( lambda C1 
                        ( lambda C2 
                           ( sum _i_Bi_key _i_Bi_val 
                              ( sum _i_p_key _i_p_val 
                                 ( var A1 ) 
                                 ( let q 
                                    ( get 
                                       ( var A1 ) 
                                       ( + 
                                          ( var _i_p_key ) 
                                          1 
                                       ) 
                                    ) 
                                    ( sing 
                                       ( var _i_p_key ) 
                                       ( sum _r_j_key _r_j_val 
                                          ( subarray 
                                             ( var A2 ) 
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
                                                ( var A3 ) 
                                                ( var _r_j_key ) 
                                             ) 
                                          ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
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
   ) 
)
