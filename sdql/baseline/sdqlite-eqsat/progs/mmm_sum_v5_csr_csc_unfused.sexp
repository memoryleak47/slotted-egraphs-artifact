( lambda A 
   ( lambda A1 
      ( lambda A2 
         ( lambda B 
            ( lambda B1 
               ( lambda B2 
                  ( let Bf 
                     ( sum _i_Bi_key _i_Bi_val 
                        ( sum _i_p_key _i_p_val 
                           ( var A ) 
                           ( let q 
                              ( get 
                                 ( var A ) 
                                 ( + 
                                    ( var _i_p_key ) 
                                    1 
                                 ) 
                              ) 
                              ( sing 
                                 ( var _i_p_key ) 
                                 ( sum _r_j_key _r_j_val 
                                    ( subarray 
                                       ( var A1 ) 
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
                                          ( var A2 ) 
                                          ( var _r_j_key ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                        ) 
                        ( sum _k1_Bik_key _k1_Bik_val 
                           ( var _i_Bi_val ) 
                           ( sing 
                              ( var _k1_Bik_key ) 
                              ( var _k1_Bik_val ) 
                           ) 
                        ) 
                     ) 
                     ( let Cf 
                        ( sum _j_Cj_key _j_Cj_val 
                           ( sum _i_p_key _i_p_val 
                              ( var B ) 
                              ( let q 
                                 ( get 
                                    ( var B ) 
                                    ( + 
                                       ( var _i_p_key ) 
                                       1 
                                    ) 
                                 ) 
                                 ( sing 
                                    ( var _i_p_key ) 
                                    ( sum _c_j_key _c_j_val 
                                       ( subarray 
                                          ( var B1 ) 
                                          ( var _i_p_val ) 
                                          ( - 
                                             ( var q ) 
                                             1 
                                          ) 
                                       ) 
                                       ( sing 
                                          ( unique 
                                             ( var _c_j_val ) 
                                          ) 
                                          ( get 
                                             ( var B2 ) 
                                             ( var _c_j_key ) 
                                          ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                           ( sum _k2_Cjk_key _k2_Cjk_val 
                              ( var _j_Cj_val ) 
                              ( sing 
                                 ( var _k2_Cjk_key ) 
                                 ( var _k2_Cjk_val ) 
                              ) 
                           ) 
                        ) 
                        ( sum _k3_Bfk_key _k3_Bfk_val 
                           ( var Bf ) 
                           ( * 
                              ( var _k3_Bfk_val ) 
                              ( get 
                                 ( var Cf ) 
                                 ( var _k3_Bfk_key ) 
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
