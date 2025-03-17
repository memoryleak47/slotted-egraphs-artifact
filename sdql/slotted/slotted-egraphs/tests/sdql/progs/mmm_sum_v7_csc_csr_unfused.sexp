( lambda $A 
   ( lambda $A1 
      ( lambda $A2 
         ( lambda $B 
            ( lambda $B1 
               ( lambda $B2 
                  ( sum $_k_Bk_key $_k_Bk_val 
                     ( sum $_i_p_key $_i_p_val 
                        ( var $A ) 
                        ( let $q 
                           ( get 
                              ( var $A ) 
                              ( + 
                                 ( var $_i_p_key ) 
                                 1 
                              ) 
                           ) 
                           ( sing 
                              ( var $_i_p_key ) 
                              ( sum $_c_j_key $_c_j_val 
                                 ( subarray 
                                    ( var $A1 ) 
                                    ( var $_i_p_val ) 
                                    ( - 
                                       ( var $q ) 
                                       1 
                                    ) 
                                 ) 
                                 ( sing 
                                    ( unique 
                                       ( var $_c_j_val ) 
                                    ) 
                                    ( get 
                                       ( var $A2 ) 
                                       ( var $_c_j_key ) 
                                    ) 
                                 ) 
                              ) 
                           ) 
                        ) 
                     ) 
                     ( sum $_i_Bki_key $_i_Bki_val 
                        ( var $_k_Bk_val ) 
                        ( * 
                           ( var $_i_Bki_val ) 
                           ( sum $_j_Ckj_key $_j_Ckj_val 
                              ( get 
                                 ( sum $_i_p_key $_i_p_val 
                                    ( var $B ) 
                                    ( let $q 
                                       ( get 
                                          ( var $B ) 
                                          ( + 
                                             ( var $_i_p_key ) 
                                             1 
                                          ) 
                                       ) 
                                       ( sing 
                                          ( var $_i_p_key ) 
                                          ( sum $_c_j_key $_c_j_val 
                                             ( subarray 
                                                ( var $B1 ) 
                                                ( var $_i_p_val ) 
                                                ( - 
                                                   ( var $q ) 
                                                   1 
                                                ) 
                                             ) 
                                             ( sing 
                                                ( unique 
                                                   ( var $_c_j_val ) 
                                                ) 
                                                ( get 
                                                   ( var $B2 ) 
                                                   ( var $_c_j_key ) 
                                                ) 
                                             ) 
                                          ) 
                                       ) 
                                    ) 
                                 ) 
                                 ( var $_k_Bk_key ) 
                              ) 
                              ( var $_j_Ckj_val ) 
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