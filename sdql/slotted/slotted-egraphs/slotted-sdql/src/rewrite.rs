use crate::*;

type SdqlRewrite = Rewrite<Sdql, SdqlKind>;

// rw!("mult-assoc1"; "(* (* ?a ?b) ?c)" => "(* ?a (* ?b ?c))"),
fn mult_assoc1() -> SdqlRewrite {
    Rewrite::new("mult-assoc1", "(* (* ?a ?b) ?c)", "(* ?a (* ?b ?c))")
}
// rw!("mult-assoc2"; "(* ?a (* ?b ?c))" => "(* (* ?a ?b) ?c)"),
fn mult_assoc2() -> SdqlRewrite {
    Rewrite::new("mult-assoc2", "(* ?a (* ?b ?c))", "(* (* ?a ?b) ?c)")
}
// rw!("sub-identity";"(- ?e ?e)"        => "0"),
fn sub_identity() -> SdqlRewrite {
    Rewrite::new("sub-identity", "(- ?e ?e)", "0")
}
// rw!("add-zero";    "(+ ?e 0)"         => "?e"),
fn add_zero() -> SdqlRewrite {
    Rewrite::new("add-zero", "(+ ?e 0)", "?e")
}
// rw!("sub-zero";    "(- ?e 0)"         => "?e"),
fn sub_zero() -> SdqlRewrite {
    Rewrite::new("sub-zero", "(- ?e 0)", "?e")
}
// rw!("eq-comm"; "(== ?a ?b)" => "(== ?b ?a)"),
fn eq_comm() -> SdqlRewrite {
    Rewrite::new("eq-comm", "(eq ?a ?b)", "(eq ?b ?a)")
}
// rw!("mult-app1"; "(* ?a ?b)" => "(binop mult ?a ?b)"),
fn mult_app1() -> SdqlRewrite {
    Rewrite::new("mult-app1", "(* ?a ?b)", "(binop mult ?a ?b)")
}
// rw!("mult-app2"; "(binop mult ?a ?b)" => "(* ?a ?b)"),
fn mult_app2() -> SdqlRewrite {
    Rewrite::new("mult-app2", "(binop mult ?a ?b)", "(* ?a ?b)")
}
// rw!("add-app1"; "(+ ?a ?b)" => "(binop add ?a ?b)"),
fn add_app1() -> SdqlRewrite {
    Rewrite::new("add-app1", "(+ ?a ?b)", "(binop add ?a ?b)")
}
// rw!("add-app2"; "(binop add ?a ?b)" => "(+ ?a ?b)"),
fn add_app2() -> SdqlRewrite {
    Rewrite::new("add-app2", "(binop add ?a ?b)", "(+ ?a ?b)")
}
// rw!("sub-app1"; "(- ?a ?b)" => "(binop sub ?a ?b)"),
fn sub_app1() -> SdqlRewrite {
    Rewrite::new("sub-app1", "(- ?a ?b)", "(binop sub ?a ?b)")
}
// rw!("sub-app2"; "(binop sub ?a ?b)" => "(- ?a ?b)"),
fn sub_app2() -> SdqlRewrite {
    Rewrite::new("sub-app2", "(binop sub ?a ?b)", "(- ?a ?b)")
}
// rw!("get-app1"; "(get ?a ?b)" => "(binop getf ?a ?b)"),
fn get_app1() -> SdqlRewrite {
    Rewrite::new("get-app1", "(get ?a ?b)", "(binop getf ?a ?b)")
}
// rw!("get-app2"; "(binop getf ?a ?b)" => "(get ?a ?b)"),
fn get_app2() -> SdqlRewrite {
    Rewrite::new("get-app2", "(binop getf ?a ?b)", "(get ?a ?b)")
}
// rw!("sing-app1"; "(sing ?a ?b)" => "(binop singf ?a ?b)"),
fn sing_app1() -> SdqlRewrite {
    Rewrite::new("sing-app1", "(sing ?a ?b)", "(binop singf ?a ?b)")
}
// rw!("sing-app2"; "(binop singf ?a ?b)" => "(sing ?a ?b)"),
fn sing_app2() -> SdqlRewrite {
    Rewrite::new("sing-app2", "(binop singf ?a ?b)", "(sing ?a ?b)")
}
// rw!("unique-app1"; "(unique ?a)" => "(apply uniquef ?a)"),
fn unique_app1() -> SdqlRewrite {
    Rewrite::new("unique-app1", "(unique ?a)", "(apply uniquef ?a)")
}
// rw!("unique-app2"; "(apply uniquef ?a)" => "(unique ?a)"),
fn unique_app2() -> SdqlRewrite {
    Rewrite::new("unique-app2", "(apply uniquef ?a)", "(unique ?a)")
}

// rw!("let-binop3"; "(let ?e1 (binop ?f ?e2 ?e3))" => "(binop ?f (let ?e1 ?e2) (let ?e1 ?e3))"),
fn let_binop3() -> SdqlRewrite {    
    Rewrite::new("let-binop3", "(let $x ?e1 (binop ?f ?e2 ?e3))", "(binop ?f (let $x ?e1 ?e2) (let $x ?e1 ?e3))")
}
// rw!("let-binop4"; "(binop ?f (let ?e1 ?e2) (let ?e1 ?e3))" => "(let ?e1 (binop ?f ?e2 ?e3))"),
fn let_binop4() -> SdqlRewrite {    
    Rewrite::new("let-binop4", "(binop ?f (let $x ?e1 ?e2) (let $x ?e1 ?e3))", "(let $x ?e1 (binop ?f ?e2 ?e3))")
}
// rw!("let-apply1"; "(let ?e1 (apply ?e2 ?e3))" => "(apply ?e2 (let ?e1 ?e3))"),
fn let_apply1() -> SdqlRewrite {    
    Rewrite::new("let-apply1", "(let $x ?e1 (apply ?e2 ?e3))", "(apply ?e2 (let $x ?e1 ?e3))")
}
// rw!("let-apply2"; "(apply ?e2 (let ?e1 ?e3))" => "(let ?e1 (apply ?e2 ?e3))"),
fn let_apply2() -> SdqlRewrite {    
    Rewrite::new("let-apply2", "(apply ?e2 (let $x ?e1 ?e3))", "(let $x ?e1 (apply ?e2 ?e3))")
}

// rw!("if-mult2"; "(* ?e1 (ifthen ?e2 ?e3))" => "(ifthen ?e2 (* ?e1 ?e3))"),
fn if_mult2() -> SdqlRewrite {
    Rewrite::new("if-mult2", "(* ?e1 (ifthen ?e2 ?e3))", "(ifthen ?e2 (* ?e1 ?e3))")
}
// rw!("if-to-mult"; "(ifthen ?e1 ?e2)" => "(* ?e1 ?e2)"),
fn if_to_mult() -> SdqlRewrite {
    Rewrite::new("if-to-mult", "(ifthen ?e1 ?e2)", "(* ?e1 ?e2)")
}
// rw!("mult-to-if"; "(* (== ?e1_1 ?e1_2) ?e2)" => "(ifthen (== ?e1_1 ?e1_2) ?e2)"),
fn mult_to_if() -> SdqlRewrite {
    Rewrite::new("mult-to-if", "(* (eq ?e1_1 ?e1_2) ?e2)", "(ifthen (eq ?e1_1 ?e1_2) ?e2)")
}

fn beta() -> SdqlRewrite {
    Rewrite::new("beta", "(let $x ?t ?body)", "?body[(var $x) := ?t]")
}

// rw!("sum-fact-1";  "(sum ?R (* ?e1 ?e2))"        => 
//     { with_shifted_double_down(var("?e1"), var("?e1d"), 2, "(* ?e1d (sum ?R ?e2))".parse::<Pattern<SDQL>>().unwrap()) }
//     if and(neg(contains_ident(var("?e1"), Index(0))), neg(contains_ident(var("?e1"), Index(1))))),
fn sum_fact_1() -> SdqlRewrite {
    let pat = "(sum $x $y ?R (* ?e1 ?e2))";
    let outpat = "(* ?e1 (sum $x $y ?R ?e2))";

    Rewrite::new_if("sum-fact-1", pat, outpat, |subst, _| {
        !subst["e1"].slots().contains(&Slot::named("x"))
        && !subst["e1"].slots().contains(&Slot::named("y"))
    })
}

// rw!("sum-fact-2";  "(sum ?R (* ?e1 ?e2))"        => 
//     { with_shifted_double_down(var("?e2"), var("?e2d"), 2, "(* (sum ?R ?e1) ?e2d)".parse::<Pattern<SDQL>>().unwrap()) }
//     if and(neg(contains_ident(var("?e2"), Index(0))), neg(contains_ident(var("?e2"), Index(1))))),
fn sum_fact_2() -> SdqlRewrite {
    let pat = "(sum $x $y ?R (* ?e1 ?e2))";
    let outpat = "(* (sum $x $y ?R ?e1) ?e2)";

    Rewrite::new_if("sum-fact-2", pat, outpat, |subst, _| {
        !subst["e2"].slots().contains(&Slot::named("x"))
        && !subst["e2"].slots().contains(&Slot::named("y"))
    })
}

//rw!("sum-fact-3";  "(sum ?R (sing ?e1 ?e2))"        => 
    //        { with_shifted_double_down(var("?e1"), var("?e1d"), 2, "(sing ?e1d (sum ?R ?e2))".parse::<Pattern<SDQL>>().unwrap()) }
    //        if and(neg(contains_ident(var("?e1"), Index(0))), neg(contains_ident(var("?e1"), Index(1))))),
fn sum_fact_3() -> SdqlRewrite {
    let pat = "(sum $x $y ?R (sing ?e1 ?e2))";
    let outpat = "(sing ?e1 (sum $x $y ?R ?e2))";

    Rewrite::new_if("sum-fact-3", pat, outpat, |subst, _| {
        !subst["e1"].slots().contains(&Slot::named("x"))
        && !subst["e1"].slots().contains(&Slot::named("y"))
    })
}

// rw!("sing-mult-1"; "(sing ?e1 (* ?e2 ?e3))" => "(* (sing ?e1 ?e2) ?e3)"),
fn sing_mult_1() -> SdqlRewrite {
    Rewrite::new("sing-mult-1", "(sing ?e1 (* ?e2 ?e3))", "(* (sing ?e1 ?e2) ?e3)")
}

// rw!("sing-mult-2"; "(sing ?e1 (* ?e2 ?e3))" => "(* ?e2 (sing ?e1 ?e3))"),
fn sing_mult_2() -> SdqlRewrite {
    Rewrite::new("sing-mult-2", "(sing ?e1 (* ?e2 ?e3))", "(* ?e2 (sing ?e1 ?e3))")
}

// rw!("sing-mult-3"; "(* (sing ?e1 ?e2) ?e3)" => "(sing ?e1 (* ?e2 ?e3))"),
fn sing_mult_3() -> SdqlRewrite {
    Rewrite::new("sing-mult-3", "(* (sing ?e1 ?e2) ?e3)", "(sing ?e1 (* ?e2 ?e3))")
}

// rw!("sing-mult-4"; "(* ?e2 (sing ?e1 ?e3))" => "(sing ?e1 (* ?e2 ?e3))"),
fn sing_mult_4() -> SdqlRewrite {
    Rewrite::new("sing-mult-4", "(* ?e2 (sing ?e1 ?e3))", "(sing ?e1 (* ?e2 ?e3))")
}

// rw!("sum-fact-inv-1";  "(* ?e1 (sum ?R ?e2))"        => 
//     { with_shifted_double_up(var("?e1"), var("?e1u"), 0, 
//         "(sum ?R (* ?e1u ?e2))".parse::<Pattern<SDQL>>().unwrap()
//     )}),
fn sum_fact_inv_1() -> SdqlRewrite {
    Rewrite::new("sum-fact-inv-1", "(* ?e1 (sum $k $v ?R ?e2))", "(sum $k $v ?R (* ?e1 ?e2))")
}

// rw!("sum-fact-inv-3";  "(sing ?e1 (sum ?R ?e2))"        => 
//     { with_shifted_double_up(var("?e1"), var("?e1u"), 0, 
//         "(sum ?R (sing ?e1u ?e2))".parse::<Pattern<SDQL>>().unwrap()
//     )}),
fn sum_fact_inv_3() -> SdqlRewrite {
    Rewrite::new("sum-fact-inv-3", "(sing ?e1 (sum $k $v ?R ?e2))", "(sum $k $v ?R (sing ?e1 ?e2))")
}

// rw!("sum-sum-vert-fuse-1";  "(sum (sum ?R (sing %1 ?body1)) ?body2)"        => 
//     { with_shifted_up(var("?body1"), var("?body1u"), 0,
//       with_shifted_double_up(var("?body2"), var("?body2u"), 2,
//         "(sum ?R (let %1 (let ?body1u ?body2u)))".parse::<Pattern<SDQL>>().unwrap()
//     ))}),
fn sum_sum_vert_fuse_1() -> SdqlRewrite {
    let pat = "(sum $k1 $v1 (sum $k2 $v2 ?R (sing (var $k2) ?body1)) ?body2)";
    let outpat = "(sum $k2 $v2 ?R (let $k1 (var $k2) (let $v1 ?body1 ?body2)))";

    Rewrite::new("sum-sum-vert-fuse-1", pat, outpat)
}

// rw!("sum-sum-vert-fuse-2";  "(sum (sum ?R (sing (unique ?key) ?body1)) ?body2)"        => 
//     { with_shifted_up(var("?body1"), var("?body1u"), 0,
//       with_shifted_double_up(var("?body2"), var("?body2u"), 2,
//         "(sum ?R (let (unique ?key) (let ?body1u ?body2u)))".parse::<Pattern<SDQL>>().unwrap()
//     ))}),
fn sum_sum_vert_fuse_2() -> SdqlRewrite {
    let pat = "(sum $k1 $v1 (sum $k2 $v2 ?R (sing (unique ?key) ?body1)) ?body2)";
    let outpat = "(sum $k2 $v2 ?R (let $k1 (unique ?key) (let $v1 ?body1 ?body2)))";

    Rewrite::new("sum-sum-vert-fuse-2", pat, outpat)
}

// rw!("get-sum-vert-fuse-1";  "(get (sum ?R (sing %1 ?body1)) ?body2)"        => 
//     { with_shifted_up(var("?R"), var("?Ru"), 0,
//         "(let ?body2 (let (get ?Ru %0) ?body1))".parse::<Pattern<SDQL>>().unwrap()
//     )}),
fn get_sum_vert_fuse_1() -> SdqlRewrite {
    let pat = "(get (sum $k $v ?R (sing (var $k) ?body1)) ?body2)";
    let outpat = "(let $k ?body2 (let $v (get ?R (var $k)) ?body1))";
    Rewrite::new("get-sum-vert-fuse-1", pat, outpat)
}

// rw!("sum-range-1";  "(sum (range ?st ?en) (ifthen (== %0 ?key) ?body))" => 
//   { with_shifted_double_up(var("?st"), var("?stu"), 0,
//     "(sum (range ?st ?en) (ifthen (== %1 (- ?key (- ?stu 1))) ?body))".parse::<Pattern<SDQL>>().unwrap()
// )}),
fn sum_range_1() -> SdqlRewrite {
    Rewrite::new("sum-range-1", 
        "(sum $k $v (range ?st ?en) (ifthen (eq (var $v) ?key) ?body))",
        "(sum $k $v (range ?st ?en) (ifthen (eq (var $k) (- ?key (- ?st 1))) ?body))")
}

// rw!("sum-range-2";  "(sum (range ?st ?en) (ifthen (== %1 ?key) ?body))"        => 
//   { with_shifted_double_down(var("?key"), var("?keyd"), 2,
//     with_shifted_up(var("?st"), var("?stu"), 0,
//     "(let ?keyd (let (+ %0 (- ?stu 1)) ?body))".parse::<Pattern<SDQL>>().unwrap()
// ))})
fn sum_range_2() -> SdqlRewrite {
    Rewrite::new_if("sum-range-2", 
        "(sum $k $v (range ?st ?en) (ifthen (eq (var $k) ?key) ?body))",
        "(let $k ?key (let $v (+ (var $k) (- ?st 1)) ?body))", |subst, _| {
        !subst["key"].slots().contains(&Slot::named("k"))
        && !subst["key"].slots().contains(&Slot::named("v"))
    })
    // adds a check for ?key to be invariant to the loop
}

// rw!("sum-merge";  "(sum ?R (sum ?S (ifthen (== %2 %0) ?body)))"        => 
//     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
//         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
//     )}),
fn sum_merge() -> SdqlRewrite {
    Rewrite::new("sum-merge", 
        "(sum $k1 $v1 ?R (sum $k2 $v2 ?S (ifthen (eq (var $v1) (var $v2)) ?body)))", 
        "(merge $k1 $k2 $v1 ?R ?S (let $v2 (var $v1) ?body))")
}

// rw!("get-to-sum";  "(get ?dict ?key)"        => 
//     { with_shifted_double_up(var("?key"), var("?keyu"), 0,
//         "(sum ?dict (ifthen (== %1 ?keyu) %0))".parse::<Pattern<SDQL>>().unwrap()
//     )}),
fn get_to_sum() -> SdqlRewrite {
    Rewrite::new("get-to-sum", 
        "(get ?dict ?key)", 
        "(sum $k $v ?dict (ifthen (eq (var $k) ?key) (var $v)))")
}

// rw!("sum-to-get";  "(sum ?R (ifthen (== %1 ?body2) ?body1))" =>
//     { with_shifted_up(var("?R"), var("?Ru"), 0,
//       with_shifted_double_down(var("?body2"), var("?body2d"), 2,
//         "(let ?body2d (let (get ?Ru %0) ?body1))".parse::<Pattern<SDQL>>().unwrap()
//     ))} if and(neg(contains_ident(var("?body2"), Index(0))), neg(contains_ident(var("?body2"), Index(1))))),
fn sum_to_get() -> SdqlRewrite {
    Rewrite::new_if("sum-to-get", 
        "(sum $k $v ?dict (ifthen (eq (var $k) ?key) ?body))", 
        "(let $k ?key (let $v (get ?dict (var $k)) ?body))", |subst, _| {
        !subst["key"].slots().contains(&Slot::named("k"))
        && !subst["key"].slots().contains(&Slot::named("v"))
    })
}

// rw!("get-range";  "(get (range ?st ?en) ?idx)"        => 
//     "(+ ?idx (- ?st 1))"),
fn get_range() -> SdqlRewrite {
    Rewrite::new("get-range", "(get (range ?st ?en) ?idx)", "(+ ?idx (- ?st 1))")
}

// rw!("sum-sing";    "(sum ?e1 (sing %1 %0))" => "?e1"),
fn sum_sing() -> SdqlRewrite {
    Rewrite::new("sum-sing", "(sum $k $v ?e1 (sing (var $k) (var $v)))", "?e1")
}
        
/*** annotation removal ***/
// rw!("unique-rm";   "(unique ?e)" => "?e"),
fn unique_rm() -> SdqlRewrite {
    Rewrite::new("unique-rm", "(unique ?e)", "?e")
}

pub fn sdql_rules_old() -> Vec<SdqlRewrite> {

    vec![
      mult_assoc1(), mult_assoc2(), sub_identity(), add_zero(), sub_zero(),
      eq_comm(),
      mult_app1(), mult_app2(), add_app1(), add_app2(), sub_app1(), sub_app2(), 
      get_app1(), get_app2(), sing_app1(), sing_app2(), unique_app1(), unique_app2(),
      let_binop3(), let_binop4(), let_apply1(), let_apply2(),
      if_mult2(), if_to_mult(), mult_to_if(),
      beta(), 
      sum_fact_1(), sum_fact_2(), sum_fact_3(),
      sing_mult_1(), sing_mult_2(), sing_mult_3(), sing_mult_4(),
      sum_fact_inv_1(),
      sum_sum_vert_fuse_1(),
      sum_sum_vert_fuse_2(),
      get_sum_vert_fuse_1(),
      sum_range_1(), sum_range_2(),
      sum_merge(),
      get_to_sum(),
      sum_sing(), unique_rm()
      ]
}

pub fn sdql_rules() -> Vec<SdqlRewrite> {

    vec![
      mult_assoc1(), mult_assoc2(), sub_identity(), add_zero(), sub_zero(),
      eq_comm(),
      mult_app1(), mult_app2(), add_app1(), add_app2(), sub_app1(), sub_app2(), 
      get_app1(), get_app2(), sing_app1(), sing_app2(), unique_app1(), unique_app2(),
      let_binop3(), let_binop4(), let_apply1(), let_apply2(),
      if_mult2(), if_to_mult(), mult_to_if(),
      beta(), 
      sum_fact_1(), sum_fact_2(), sum_fact_3(),
      sing_mult_1(), sing_mult_2(), sing_mult_3(), sing_mult_4(),
      sum_fact_inv_1(), sum_fact_inv_3(),
      sum_sum_vert_fuse_1(),
      sum_sum_vert_fuse_2(),
      sum_range_1(), 
      sum_merge(),
      get_to_sum(), sum_to_get(), get_range(),
      sum_sing(), unique_rm()
      ]
}

