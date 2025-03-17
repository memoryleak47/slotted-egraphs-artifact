( lambda B_curried 
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
                     ( var B_curried ) 
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