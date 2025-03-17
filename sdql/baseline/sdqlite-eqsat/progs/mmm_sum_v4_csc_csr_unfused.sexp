( lambda A 
   ( lambda A1 
      ( lambda A2 
         ( lambda B 
            ( lambda B1 
               ( lambda B2 
                  ( let Bf 
                     ( sum _k_Bk_key _k_Bk_val 
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
                                 ( sum _c_j_key _c_j_val 
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
                                          ( var _c_j_val ) 
                                       ) 
                                       ( get 
                                          ( var A2 ) 
                                          ( var _c_j_key ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                        ) 
                        ( sing 
                           ( var _k_Bk_key ) 
                           ( sum _k_Bik_key _k_Bik_val 
                              ( var _k_Bk_val ) 
                              ( var _k_Bik_val ) 
                           ) 
                        ) 
                     ) 
                     ( sum _k2_Ck_key _k2_Ck_val 
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
                        ( * 
                           ( get 
                              ( var Bf ) 
                              ( var _k2_Ck_key ) 
                           ) 
                           ( sum _j_Ckj_key _j_Ckj_val 
                              ( var _k2_Ck_val ) 
                              ( var _j_Ckj_val ) 
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
