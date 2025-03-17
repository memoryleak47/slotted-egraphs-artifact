( lambda CSR_col 
   ( lambda CSR_val 
      ( lambda D_curried 
         ( sum _i_Bi_key _i_Bi_val 
            ( var D_curried ) 
            ( sum _j_Bij_key _j_Bij_val 
               ( var _i_Bi_val ) 
               ( sum _k_Ck_key _k_Ck_val 
                  ( sum _i_p_key _i_p_val 
                     ( var CSR_col ) 
                     ( let q 
                        ( get 
                           ( var CSR_col ) 
                           ( + 
                              ( var _i_p_key ) 
                              1 
                           ) 
                        ) 
                        ( sum _rr_r_key _rr_r_val 
                           ( range 
                              ( var _i_p_val ) 
                              ( - 
                                 ( var q ) 
                                 1 
                              ) 
                           ) 
                           ( let j 
                              ( get 
                                 ( var CSR_col ) 
                                 ( var _rr_r_val ) 
                              ) 
                              ( let v 
                                 ( get 
                                    ( var CSR_val ) 
                                    ( var _rr_r_val ) 
                                 ) 
                                 ( sing 
                                    ( unique 
                                       ( var j ) 
                                    ) 
                                    ( sing 
                                       ( unique 
                                          ( var _i_p_key ) 
                                       ) 
                                       ( var v ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                        ) 
                     ) 
                  ) 
                  ( sum _l_B_v_key _l_B_v_val 
                     ( var _j_Bij_val ) 
                     ( sing 
                        ( var _i_Bi_key ) 
                        ( sing 
                           ( var _j_Bij_key ) 
                           ( sing 
                              ( var _k_Ck_key ) 
                              ( * 
                                 ( var _l_B_v_val ) 
                                 ( get 
                                    ( var _k_Ck_val ) 
                                    ( var _l_B_v_key ) 
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
