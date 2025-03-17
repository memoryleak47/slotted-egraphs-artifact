( lambda B1 
   ( lambda B2 
      ( lambda B3 
         ( lambda B4 
            ( lambda B5 
               ( lambda B6 
                  ( lambda C1 
                     ( lambda C2 
                        ( lambda C3 
                           ( lambda D1 
                              ( lambda D2 
                                 ( lambda D3 
                                    ( sum _i_Bi_key _i_Bi_val 
                                       ( sum _i_row_idx_key _i_row_idx_val 
                                          ( var B1 ) 
                                          ( let p 
                                             ( get 
                                                ( var B2 ) 
                                                ( var _i_row_idx_key ) 
                                             ) 
                                             ( let q 
                                                ( get 
                                                   ( var B2 ) 
                                                   ( + 
                                                      ( var _i_row_idx_key ) 
                                                      1 
                                                   ) 
                                                ) 
                                                ( sing 
                                                   ( unique 
                                                      ( var _i_row_idx_val ) 
                                                   ) 
                                                   ( sum _r_col_idx_key _r_col_idx_val 
                                                      ( subarray 
                                                         ( var B3 ) 
                                                         ( var p ) 
                                                         ( - 
                                                            ( var q ) 
                                                            1 
                                                         ) 
                                                      ) 
                                                      ( let p2 
                                                         ( get 
                                                            ( var B4 ) 
                                                            ( var _r_col_idx_key ) 
                                                         ) 
                                                         ( let q2 
                                                            ( get 
                                                               ( var B4 ) 
                                                               ( + 
                                                                  ( var _r_col_idx_key ) 
                                                                  1 
                                                               ) 
                                                            ) 
                                                            ( sing 
                                                               ( unique 
                                                                  ( var _r_col_idx_val ) 
                                                               ) 
                                                               ( sum _c_col2_idx_key _c_col2_idx_val 
                                                                  ( subarray 
                                                                     ( var B5 ) 
                                                                     ( var p2 ) 
                                                                     ( - 
                                                                        ( var q2 ) 
                                                                        1 
                                                                     ) 
                                                                  ) 
                                                                  ( let v 
                                                                     ( get 
                                                                        ( var B6 ) 
                                                                        ( var _c_col2_idx_key ) 
                                                                     ) 
                                                                     ( sing 
                                                                        ( unique 
                                                                           ( var _c_col2_idx_val ) 
                                                                        ) 
                                                                        ( var v ) 
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
                                       ( sing 
                                          ( var _i_Bi_key ) 
                                          ( sum _k_Bik_key _k_Bik_val 
                                             ( var _i_Bi_val ) 
                                             ( sum _l_B_v_key _l_B_v_val 
                                                ( var _k_Bik_val ) 
                                                ( sum _j_D_v_key _j_D_v_val 
                                                   ( get 
                                                      ( sum _rr_r_key _rr_r_val 
                                                         ( range 
                                                            1 
                                                            ( var D2 ) 
                                                         ) 
                                                         ( sing 
                                                            ( unique 
                                                               ( var _rr_r_val ) 
                                                            ) 
                                                            ( sum _cc_c_key _cc_c_val 
                                                               ( range 
                                                                  1 
                                                                  ( var D3 ) 
                                                               ) 
                                                               ( sing 
                                                                  ( unique 
                                                                     ( var _cc_c_val ) 
                                                                  ) 
                                                                  ( get 
                                                                     ( var D1 ) 
                                                                     ( + 
                                                                        ( * 
                                                                           ( - 
                                                                              ( var _rr_r_val ) 
                                                                              1 
                                                                           ) 
                                                                           ( var D3 ) 
                                                                        ) 
                                                                        ( var _cc_c_val ) 
                                                                     ) 
                                                                  ) 
                                                               ) 
                                                            ) 
                                                         ) 
                                                      ) 
                                                      ( var _l_B_v_key ) 
                                                   ) 
                                                   ( sing 
                                                      ( var _j_D_v_key ) 
                                                      ( * 
                                                         ( * 
                                                            ( var _l_B_v_val ) 
                                                            ( get 
                                                               ( get 
                                                                  ( sum _rr_r_key _rr_r_val 
                                                                     ( range 
                                                                        1 
                                                                        ( var C2 ) 
                                                                     ) 
                                                                     ( sing 
                                                                        ( unique 
                                                                           ( var _rr_r_val ) 
                                                                        ) 
                                                                        ( sum _cc_c_key _cc_c_val 
                                                                           ( range 
                                                                              1 
                                                                              ( var C3 ) 
                                                                           ) 
                                                                           ( sing 
                                                                              ( unique 
                                                                                 ( var _cc_c_val ) 
                                                                              ) 
                                                                              ( get 
                                                                                 ( var C1 ) 
                                                                                 ( + 
                                                                                    ( * 
                                                                                       ( - 
                                                                                          ( var _rr_r_val ) 
                                                                                          1 
                                                                                       ) 
                                                                                       ( var C3 ) 
                                                                                    ) 
                                                                                    ( var _cc_c_val ) 
                                                                                 ) 
                                                                              ) 
                                                                           ) 
                                                                        ) 
                                                                     ) 
                                                                  ) 
                                                                  ( var _k_Bik_key ) 
                                                               ) 
                                                               ( var _j_D_v_key ) 
                                                            ) 
                                                         ) 
                                                         ( var _j_D_v_val ) 
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
)
