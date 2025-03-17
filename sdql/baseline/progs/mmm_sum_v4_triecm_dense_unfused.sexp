( lambda A 
   ( lambda B 
      ( lambda B1 
         ( lambda B2 
            ( let Bf 
               ( sum _k_Bk_key _k_Bk_val 
                  ( var A ) 
                  ( sing 
                     ( var _k_Bk_key ) 
                     ( sum _k_Bik_key _k_Bik_val 
                        ( var _k_Bk_val ) 
                        ( var _k_Bik_val ) 
                     ) 
                  ) 
               ) 
               ( sum _k2_Ck_key _k2_Ck_val 
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