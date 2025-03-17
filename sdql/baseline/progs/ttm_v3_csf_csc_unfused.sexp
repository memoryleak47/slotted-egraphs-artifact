( lambda A1 
   ( lambda A2 
      ( lambda A3 
         ( lambda B1 
            ( lambda B2 
               ( lambda B3 
                  ( lambda B4 
                     ( lambda B5 
                        ( lambda B6 
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
                                 ( sum _j_Bij_key _j_Bij_val 
                                    ( var _i_Bi_val ) 
                                    ( sing 
                                       ( var _j_Bij_key ) 
                                       ( sum _l_B_v_key _l_B_v_val 
                                          ( var _j_Bij_val ) 
                                          ( sum _k_Clk_key _k_Clk_val 
                                             ( get 
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
                                                         ( sum _c_j_key _c_j_val 
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
                                                                  ( var _c_j_val ) 
                                                               ) 
                                                               ( get 
                                                                  ( var A3 ) 
                                                                  ( var _c_j_key ) 
                                                               ) 
                                                            ) 
                                                         ) 
                                                      ) 
                                                   ) 
                                                ) 
                                                ( var _l_B_v_key ) 
                                             ) 
                                             ( sing 
                                                ( var _k_Clk_key ) 
                                                ( * 
                                                   ( var _l_B_v_val ) 
                                                   ( var _k_Clk_val ) 
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