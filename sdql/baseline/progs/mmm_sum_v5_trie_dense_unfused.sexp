( lambda A 
   ( lambda B 
      ( lambda B1 
         ( lambda B2 
            ( let Bf 
               ( sum _i_Bi_key _i_Bi_val 
                  ( var A ) 
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
                     ( sum _cc_c_key _cc_c_val 
                        ( range 
                           1 
                           ( var B2 ) 
                        ) 
                        ( sing 
                           ( unique 
                              ( var _cc_c_val ) 
                           ) 
                           ( sum _rr_r_key _rr_r_val 
                              ( range 
                                 1 
                                 ( var B1 ) 
                              ) 
                              ( sing 
                                 ( unique 
                                    ( var _rr_r_val ) 
                                 ) 
                                 ( get 
                                    ( var B ) 
                                    ( + 
                                       ( * 
                                          ( - 
                                             ( var _cc_c_val ) 
                                             1 
                                          ) 
                                          ( var B1 ) 
                                       ) 
                                       ( var _rr_r_val ) 
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
