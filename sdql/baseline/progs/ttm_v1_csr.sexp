( lambda CSR_col 
   ( lambda CSR_row 
      ( lambda CSR_val 
         ( lambda D_curried 
            ( sum _i_Bi_key _i_Bi_val 
               ( var D_curried ) 
               ( sing 
                  ( var _i_Bi_key ) 
                  ( sum _j_Bij_key _j_Bij_val 
                     ( var _i_Bi_val ) 
                     ( sing 
                        ( var _j_Bij_key ) 
                        ( sum _k_Ck_key _k_Ck_val 
                           ( sum _i_p_key _i_p_val 
                              ( var CSR_row ) 
                              ( let q 
                                 ( get 
                                    ( var CSR_row ) 
                                    ( + 
                                       ( var _i_p_key ) 
                                       1 
                                    ) 
                                 ) 
                                 ( sing 
                                    ( var _i_p_key ) 
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
                                                ( var v ) 
                                             ) 
                                          ) 
                                       ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                           ( sing 
                              ( var _k_Ck_key ) 
                              ( sum _l_B_v_key _l_B_v_val 
                                 ( var _j_Bij_val ) 
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
)
