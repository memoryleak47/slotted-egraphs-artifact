use crate::sdql::*;
use crate::sdql::EGraph;
use crate::sdqlsubstitute::*;
use std::collections::HashMap;
use egg::{EGraph as EGGEGraph, rewrite as rw, *};

fn var(s: &str) -> Var {
    s.parse().unwrap()
}

fn contains_ident(v1: Var, index: Index) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    move |egraph, _, subst| egraph[subst[v1]].data.free.contains(&index)
}

fn neg(f: impl Fn(&mut EGraph, Id, &Subst) -> bool) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    move |egraph, id, subst| !f(egraph, id, subst)
}

fn and(f1: impl Fn(&mut EGraph, Id, &Subst) -> bool, f2: impl Fn(&mut EGraph, Id, &Subst) -> bool) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    move |egraph, id, subst| f1(egraph, id, subst) && f2(egraph, id, subst)
}

pub fn rules_old() -> Vec<Rewrite<SDQL, SDQLAnalysis>> {
    vec![
        /*** algebraic rules ***/
        rw!("mult-assoc1"; "(* (* ?a ?b) ?c)" => "(* ?a (* ?b ?c))"),
        rw!("mult-assoc2"; "(* ?a (* ?b ?c))" => "(* (* ?a ?b) ?c)"),
        rw!("sub-identity";"(- ?e ?e)"        => "0"),
        rw!("add-zero";    "(+ ?e 0)"         => "?e"),
        rw!("sub-zero";    "(- ?e 0)"         => "?e"),
        // rw!("mult-zero";    "(* ?e 0)"         => "0"),
        // rw!("mult-one1";    "(* ?e 1)"         => "?e"),
        // rw!("mult-one2";    "(* 1 ?e)"         => "?e"),
        // rw!("mult-dist1"; "(* (+ ?a ?b) ?c)" => "(+ (* ?a ?c) (* ?b ?c))"),
        // rw!("mult-dist2"; "(* ?a (+ ?b ?c))" => "(+ (* ?a ?b) (* ?a ?c))"),
        rw!("eq-comm"; "(== ?a ?b)" => "(== ?b ?a)"),
        // rw!("add-comm"; "(+ ?a ?b)" => "(+ ?b ?a)"),
        /*** dictionary rules ***/
        // rw!("sing-add1";    "(+ (sing ?e1 ?e2) (sing ?e1 ?e3))"         => "(sing ?e1 (+ ?e2 ?e3))"),
        // rw!("sing-add2";    "(sing ?e1 (+ ?e2 ?e3))"                    => "(+ (sing ?e1 ?e2) (sing ?e1 ?e3))"),
        /*** normalize constructs to unary and binary operators ***/
        rw!("mult-app1"; "(* ?a ?b)" => "(binop mult ?a ?b)"),
        rw!("mult-app2"; "(binop mult ?a ?b)" => "(* ?a ?b)"),
        rw!("add-app1"; "(+ ?a ?b)" => "(binop add ?a ?b)"),
        rw!("add-app2"; "(binop add ?a ?b)" => "(+ ?a ?b)"),
        rw!("sub-app1"; "(- ?a ?b)" => "(binop sub ?a ?b)"),
        rw!("sub-app2"; "(binop sub ?a ?b)" => "(- ?a ?b)"),
        rw!("get-app1"; "(get ?a ?b)" => "(binop getf ?a ?b)"),
        rw!("get-app2"; "(binop getf ?a ?b)" => "(get ?a ?b)"),
        rw!("sing-app1"; "(sing ?a ?b)" => "(binop singf ?a ?b)"),
        rw!("sing-app2"; "(binop singf ?a ?b)" => "(sing ?a ?b)"),
        rw!("unique-app1"; "(unique ?a)" => "(apply uniquef ?a)"),
        rw!("unique-app2"; "(apply uniquef ?a)" => "(unique ?a)"),
        /*** let-floating for binary and unary operators ***/
        rw!("let-binop3"; "(let ?e1 (binop ?f ?e2 ?e3))" => "(binop ?f (let ?e1 ?e2) (let ?e1 ?e3))"),
        rw!("let-binop4"; "(binop ?f (let ?e1 ?e2) (let ?e1 ?e3))" => "(let ?e1 (binop ?f ?e2 ?e3))"),
        rw!("let-apply1"; "(let ?e1 (apply ?e2 ?e3))" => "(apply ?e2 (let ?e1 ?e3))"),
        rw!("let-apply2"; "(apply ?e2 (let ?e1 ?e3))" => "(let ?e1 (apply ?e2 ?e3))"),
        /*** if-then-else ***/
        //// REP `(* (ifthen ?e1 ?e2) ?e3)` -> `(* (* ?e1 ?e2) ?e3)` -> `(* ?e1 (* ?e2 ?e3))` -> `(ifthen ?e1 (* ?e2 ?e3))`
        // rw!("if-mult1"; "(* (ifthen ?e1 ?e2) ?e3)" => "(ifthen ?e1 (* ?e2 ?e3))"),
        rw!("if-mult2"; "(* ?e1 (ifthen ?e2 ?e3))" => "(ifthen ?e2 (* ?e1 ?e3))"),
        /*** if-then-else normalization ***/
        rw!("if-to-mult"; "(ifthen ?e1 ?e2)" => "(* ?e1 ?e2)"),
        rw!("mult-to-if"; "(* (== ?e1_1 ?e1_2) ?e2)" => "(ifthen (== ?e1_1 ?e1_2) ?e2)"),
        /*** beta-reduction ***/
        rw!("beta"; "(let ?e ?body)" =>
            { BetaExtractApplier { body: var("?body"), subs: var("?e") } }),
        /*** sum-factorization ***/
        rw!("sum-fact-1";  "(sum ?R (* ?e1 ?e2))"        => 
            { with_shifted_double_down(var("?e1"), var("?e1d"), 2, "(* ?e1d (sum ?R ?e2))".parse::<Pattern<SDQL>>().unwrap()) }
            if and(neg(contains_ident(var("?e1"), Index(0))), neg(contains_ident(var("?e1"), Index(1))))),
        rw!("sum-fact-2";  "(sum ?R (* ?e1 ?e2))"        => 
            { with_shifted_double_down(var("?e2"), var("?e2d"), 2, "(* (sum ?R ?e1) ?e2d)".parse::<Pattern<SDQL>>().unwrap()) }
            if and(neg(contains_ident(var("?e2"), Index(0))), neg(contains_ident(var("?e2"), Index(1))))),
        rw!("sum-fact-3";  "(sum ?R (sing ?e1 ?e2))"        => 
            { with_shifted_double_down(var("?e1"), var("?e1d"), 2, "(sing ?e1d (sum ?R ?e2))".parse::<Pattern<SDQL>>().unwrap()) }
            if and(neg(contains_ident(var("?e1"), Index(0))), neg(contains_ident(var("?e1"), Index(1))))),
        /*** sing-mult associativity ***/
        rw!("sing-mult-1"; "(sing ?e1 (* ?e2 ?e3))" => "(* (sing ?e1 ?e2) ?e3)"),
        rw!("sing-mult-2"; "(sing ?e1 (* ?e2 ?e3))" => "(* ?e2 (sing ?e1 ?e3))"),
        rw!("sing-mult-3"; "(* (sing ?e1 ?e2) ?e3)" => "(sing ?e1 (* ?e2 ?e3))"),
        rw!("sing-mult-4"; "(* ?e2 (sing ?e1 ?e3))" => "(sing ?e1 (* ?e2 ?e3))"),
        /*** sum-defactorization ***/
        rw!("sum-fact-inv-1";  "(* ?e1 (sum ?R ?e2))"        => 
            { with_shifted_double_up(var("?e1"), var("?e1u"), 0, 
                "(sum ?R (* ?e1u ?e2))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        // rw!("sum-fact-inv-3";  "(sing ?e1 (sum ?R ?e2))"        => 
        //     { with_shifted_double_up(var("?e1"), var("?e1u"), 0, 
        //         "(sum ?R (sing ?e1u ?e2))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** sum-sum vertical fusion ***/
        rw!("sum-sum-vert-fuse-1";  "(sum (sum ?R (sing %1 ?body1)) ?body2)"        => 
            { with_shifted_up(var("?body1"), var("?body1u"), 0,
              with_shifted_double_up(var("?body2"), var("?body2u"), 2,
                "(sum ?R (let %1 (let ?body1u ?body2u)))".parse::<Pattern<SDQL>>().unwrap()
            ))}),
        rw!("sum-sum-vert-fuse-2";  "(sum (sum ?R (sing (unique ?key) ?body1)) ?body2)"        => 
            { with_shifted_up(var("?body1"), var("?body1u"), 0,
              with_shifted_double_up(var("?body2"), var("?body2u"), 2,
                "(sum ?R (let (unique ?key) (let ?body1u ?body2u)))".parse::<Pattern<SDQL>>().unwrap()
            ))}),
        /*** get-sum vertical fusion ***/
        //// REP, it is subsumed by `sum-sum-vert-fuse-1` and `get-to-sum` and `sum-to-get`
        ////      `(get (sum ?R (sing %1 ?body1)) ?body2)` -> (`get-to-sum`)
        ////      `(sum (sum ?R (sing %1 ?body1)) (ifthen (== %1 ?body2u) %0))` -> (`sum-sum-vert-fuse-1`)
        ////      `(sum ?R (let %1 (let ?body1u (ifthen (== %1 ?body2uu) %0))))` -> (`beta`)
        ////      `(sum ?R (ifthen (== %1 ?body2u) ?body1))` -> (`sum-to-get`)
        ////      `(let ?body2 (let (get ?Ru %0) ?body1))`
        rw!("get-sum-vert-fuse-1";  "(get (sum ?R (sing %1 ?body1)) ?body2)"        => 
            { with_shifted_up(var("?R"), var("?Ru"), 0,
                "(let ?body2 (let (get ?Ru %0) ?body1))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        //// REP, already subsumed and generalized (key doesn't need to be unique) by `sum-sum-vert-fuse-2` and `get-to-sum`
        ////     `(get (sum ?R (sing (unique ?key) ?body1)) ?body2)` -> (`get-to-sum`)
        ////     `(sum (sum ?R (sing (unique ?key) ?body1)) (ifthen (== %1 ?body2u) %0))` -> (`sum-sum-vert-fuse-2`)
        ////     `(sum ?R (let (unique ?key) (let ?body1u (ifthen (== %1 ?body2uu) %0))))` -> (`beta`)
        ////     `(sum ?R (ifthen (== (unique ?key) ?body2u) ?body1))` 
        // rw!("get-sum-vert-fuse-2";  "(get (sum ?R (sing (unique ?key) ?body1)) ?body2)"        => 
        //     { with_shifted_double_up(var("?body2"), var("?body2u"), 0,
        //         "(sum ?R (ifthen (== ?key ?body2u) ?body1))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** sum-range vertical fusion ***/
        rw!("sum-range-1";  "(sum (range ?st ?en) (ifthen (== %0 ?key) ?body))" => 
              { with_shifted_double_up(var("?st"), var("?stu"), 0,
                "(sum (range ?st ?en) (ifthen (== %1 (- ?key (- ?stu 1))) ?body))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        rw!("sum-range-2";  "(sum (range ?st ?en) (ifthen (== %1 ?key) ?body))"        => 
              { with_shifted_double_down(var("?key"), var("?keyd"), 2,
                with_shifted_up(var("?st"), var("?stu"), 0,
                "(let ?keyd (let (+ %0 (- ?stu 1)) ?body))".parse::<Pattern<SDQL>>().unwrap()
            ))} if and(neg(contains_ident(var("?key"), Index(0))), neg(contains_ident(var("?key"), Index(1)))) ),// if and(neg(contains_ident(var("?key"), Index(0))), neg(contains_ident(var("?key"), Index(1)))) ),
        //// REP, generalized by `sum-range-1` and `sum-range-2` and algebraic rules
        // rw!("sum-range-3";  "(sum (range 1 ?en) (ifthen (== %0 ?key) ?body))"        => 
        //       { with_shifted_double_down(var("?key"), var("?keyd"), 2,
        //         "(let ?keyd (let %0 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed by `sum-range-3` and `unique-rm`
        // rw!("sum-range-4";  "(sum (range 1 ?en) (ifthen (== (unique %0) ?key) ?body))"        => 
        //       { with_shifted_double_down(var("?key"), var("?keyd"), 2,
        //         "(let ?keyd (let %0 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** nested sum to merge conversion ***/
        rw!("sum-merge";  "(sum ?R (sum ?S (ifthen (== %2 %0) ?body)))"        => 
            { with_shifted_double_down(var("?S"), var("?Sd"), 2,
                "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        //// REP, already subsumted by sum-merge and unique-rm
        // rw!("sum-merge-2";  "(sum ?R (sum ?S (ifthen (== %0 (unique %2)) ?body)))"        => 
        //     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
        //         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed by sum-merge and eq-comm
        // rw!("sum-merge-3";  "(sum ?R (sum ?S (ifthen (== %0 %2) ?body)))"        => 
        //     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
        //         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed by sum-merge-3 and eq-comm
        // rw!("sum-merge-4";  "(sum ?R (sum ?S (ifthen (== (unique %2) %0) ?body)))"        => 
        //     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
        //         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** merge simplifier ***/
        //// REP, already subsumed by sum-range-1 (it's even a better version)
        // rw!("merge-sum-1";  "(merge (range ?st ?en1) (range ?st ?en2) ?body)"        => 
        //       "(sum (range ?st (binop min ?en1 ?en2)) (let %1 ?body))"
        //     ),
        /*** get and sum conversion ***/
        rw!("get-to-sum";  "(get ?dict ?key)"        => 
            { with_shifted_double_up(var("?key"), var("?keyu"), 0,
                "(sum ?dict (ifthen (== %1 ?keyu) %0))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        // rw!("sum-to-get";  "(sum ?R (ifthen (== %1 ?body2) ?body1))" =>
        //     { with_shifted_up(var("?R"), var("?Ru"), 0,
        //       with_shifted_double_down(var("?body2"), var("?body2d"), 2,
        //         "(let ?body2d (let (get ?Ru %0) ?body1))".parse::<Pattern<SDQL>>().unwrap()
        //     ))} if and(neg(contains_ident(var("?body2"), Index(0))), neg(contains_ident(var("?body2"), Index(1))))),
        // rw!("get-range";  "(get (range ?st ?en) ?idx)"        => 
        //     "(+ ?idx (- ?st 1))"),
        /*** sum simplifier  ***/
        // Can be generalized 
        // 1. similar to get-sum-range
        // rw!("get-sum-range-1";  "(get (sum (range 1 ?en) (sing (unique %0) ?body)) ?idx)"        => 
        //         "(let ?idx (let %0 ?body))"
        // ),
        rw!("sum-sing";    "(sum ?e1 (sing %1 %0))" => "?e1"),
        /*** annotation removal ***/
        rw!("unique-rm";   "(unique ?e)" => "?e"),
    ]
}

pub fn rules() -> Vec<Rewrite<SDQL, SDQLAnalysis>> {
    vec![
        /*** algebraic rules ***/
        rw!("mult-assoc1"; "(* (* ?a ?b) ?c)" => "(* ?a (* ?b ?c))"),
        rw!("mult-assoc2"; "(* ?a (* ?b ?c))" => "(* (* ?a ?b) ?c)"),
        rw!("sub-identity";"(- ?e ?e)"        => "0"),
        rw!("add-zero";    "(+ ?e 0)"         => "?e"),
        rw!("sub-zero";    "(- ?e 0)"         => "?e"),
        // rw!("mult-zero";    "(* ?e 0)"         => "0"),
        // rw!("mult-one1";    "(* ?e 1)"         => "?e"),
        // rw!("mult-one2";    "(* 1 ?e)"         => "?e"),
        // rw!("mult-dist1"; "(* (+ ?a ?b) ?c)" => "(+ (* ?a ?c) (* ?b ?c))"),
        // rw!("mult-dist2"; "(* ?a (+ ?b ?c))" => "(+ (* ?a ?b) (* ?a ?c))"),
        rw!("eq-comm"; "(== ?a ?b)" => "(== ?b ?a)"),
        // rw!("add-comm"; "(+ ?a ?b)" => "(+ ?b ?a)"),
        /*** dictionary rules ***/
        // rw!("sing-add1";    "(+ (sing ?e1 ?e2) (sing ?e1 ?e3))"         => "(sing ?e1 (+ ?e2 ?e3))"),
        // rw!("sing-add2";    "(sing ?e1 (+ ?e2 ?e3))"                    => "(+ (sing ?e1 ?e2) (sing ?e1 ?e3))"),
        /*** normalize constructs to unary and binary operators ***/
        rw!("mult-app1"; "(* ?a ?b)" => "(binop mult ?a ?b)"),
        rw!("mult-app2"; "(binop mult ?a ?b)" => "(* ?a ?b)"),
        rw!("add-app1"; "(+ ?a ?b)" => "(binop add ?a ?b)"),
        rw!("add-app2"; "(binop add ?a ?b)" => "(+ ?a ?b)"),
        rw!("sub-app1"; "(- ?a ?b)" => "(binop sub ?a ?b)"),
        rw!("sub-app2"; "(binop sub ?a ?b)" => "(- ?a ?b)"),
        rw!("get-app1"; "(get ?a ?b)" => "(binop getf ?a ?b)"),
        rw!("get-app2"; "(binop getf ?a ?b)" => "(get ?a ?b)"),
        rw!("sing-app1"; "(sing ?a ?b)" => "(binop singf ?a ?b)"),
        rw!("sing-app2"; "(binop singf ?a ?b)" => "(sing ?a ?b)"),
        rw!("unique-app1"; "(unique ?a)" => "(apply uniquef ?a)"),
        rw!("unique-app2"; "(apply uniquef ?a)" => "(unique ?a)"),
        /*** let-floating for binary and unary operators ***/
        rw!("let-binop3"; "(let ?e1 (binop ?f ?e2 ?e3))" => "(binop ?f (let ?e1 ?e2) (let ?e1 ?e3))"),
        rw!("let-binop4"; "(binop ?f (let ?e1 ?e2) (let ?e1 ?e3))" => "(let ?e1 (binop ?f ?e2 ?e3))"),
        rw!("let-apply1"; "(let ?e1 (apply ?e2 ?e3))" => "(apply ?e2 (let ?e1 ?e3))"),
        rw!("let-apply2"; "(apply ?e2 (let ?e1 ?e3))" => "(let ?e1 (apply ?e2 ?e3))"),
        /*** if-then-else ***/
        //// REP `(* (ifthen ?e1 ?e2) ?e3)` -> `(* (* ?e1 ?e2) ?e3)` -> `(* ?e1 (* ?e2 ?e3))` -> `(ifthen ?e1 (* ?e2 ?e3))`
        // rw!("if-mult1"; "(* (ifthen ?e1 ?e2) ?e3)" => "(ifthen ?e1 (* ?e2 ?e3))"),
        rw!("if-mult2"; "(* ?e1 (ifthen ?e2 ?e3))" => "(ifthen ?e2 (* ?e1 ?e3))"),
        /*** if-then-else normalization ***/
        rw!("if-to-mult"; "(ifthen ?e1 ?e2)" => "(* ?e1 ?e2)"),
        rw!("mult-to-if"; "(* (== ?e1_1 ?e1_2) ?e2)" => "(ifthen (== ?e1_1 ?e1_2) ?e2)"),
        /*** beta-reduction ***/
        rw!("beta"; "(let ?e ?body)" =>
            { BetaExtractApplier { body: var("?body"), subs: var("?e") } }),
        /*** sum-factorization ***/
        rw!("sum-fact-1";  "(sum ?R (* ?e1 ?e2))"        => 
            { with_shifted_double_down(var("?e1"), var("?e1d"), 2, "(* ?e1d (sum ?R ?e2))".parse::<Pattern<SDQL>>().unwrap()) }
            if and(neg(contains_ident(var("?e1"), Index(0))), neg(contains_ident(var("?e1"), Index(1))))),
        rw!("sum-fact-2";  "(sum ?R (* ?e1 ?e2))"        => 
            { with_shifted_double_down(var("?e2"), var("?e2d"), 2, "(* (sum ?R ?e1) ?e2d)".parse::<Pattern<SDQL>>().unwrap()) }
            if and(neg(contains_ident(var("?e2"), Index(0))), neg(contains_ident(var("?e2"), Index(1))))),
        rw!("sum-fact-3";  "(sum ?R (sing ?e1 ?e2))"        => 
            { with_shifted_double_down(var("?e1"), var("?e1d"), 2, "(sing ?e1d (sum ?R ?e2))".parse::<Pattern<SDQL>>().unwrap()) }
            if and(neg(contains_ident(var("?e1"), Index(0))), neg(contains_ident(var("?e1"), Index(1))))),
        /*** sing-mult associativity ***/
        rw!("sing-mult-1"; "(sing ?e1 (* ?e2 ?e3))" => "(* (sing ?e1 ?e2) ?e3)"),
        rw!("sing-mult-2"; "(sing ?e1 (* ?e2 ?e3))" => "(* ?e2 (sing ?e1 ?e3))"),
        rw!("sing-mult-3"; "(* (sing ?e1 ?e2) ?e3)" => "(sing ?e1 (* ?e2 ?e3))"),
        rw!("sing-mult-4"; "(* ?e2 (sing ?e1 ?e3))" => "(sing ?e1 (* ?e2 ?e3))"),
        /*** sum-defactorization ***/
        rw!("sum-fact-inv-1";  "(* ?e1 (sum ?R ?e2))"        => 
            { with_shifted_double_up(var("?e1"), var("?e1u"), 0, 
                "(sum ?R (* ?e1u ?e2))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        rw!("sum-fact-inv-3";  "(sing ?e1 (sum ?R ?e2))"        => 
            { with_shifted_double_up(var("?e1"), var("?e1u"), 0, 
                "(sum ?R (sing ?e1u ?e2))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        /*** sum-sum vertical fusion ***/
        rw!("sum-sum-vert-fuse-1";  "(sum (sum ?R (sing %1 ?body1)) ?body2)"        => 
            { with_shifted_up(var("?body1"), var("?body1u"), 0,
              with_shifted_double_up(var("?body2"), var("?body2u"), 2,
                "(sum ?R (let %1 (let ?body1u ?body2u)))".parse::<Pattern<SDQL>>().unwrap()
            ))}),
        rw!("sum-sum-vert-fuse-2";  "(sum (sum ?R (sing (unique ?key) ?body1)) ?body2)"        => 
            { with_shifted_up(var("?body1"), var("?body1u"), 0,
              with_shifted_double_up(var("?body2"), var("?body2u"), 2,
                "(sum ?R (let (unique ?key) (let ?body1u ?body2u)))".parse::<Pattern<SDQL>>().unwrap()
            ))}),
        /*** get-sum vertical fusion ***/
        //// REP, it is subsumed by `sum-sum-vert-fuse-1` and `get-to-sum` and `sum-to-get`
        ////      `(get (sum ?R (sing %1 ?body1)) ?body2)` -> (`get-to-sum`)
        ////      `(sum (sum ?R (sing %1 ?body1)) (ifthen (== %1 ?body2u) %0))` -> (`sum-sum-vert-fuse-1`)
        ////      `(sum ?R (let %1 (let ?body1u (ifthen (== %1 ?body2uu) %0))))` -> (`beta`)
        ////      `(sum ?R (ifthen (== %1 ?body2u) ?body1))` -> (`sum-to-get`)
        ////      `(let ?body2 (let (get ?Ru %0) ?body1))`
        // rw!("get-sum-vert-fuse-1";  "(get (sum ?R (sing %1 ?body1)) ?body2)"        => 
        //     { with_shifted_up(var("?R"), var("?Ru"), 0,
        //         "(let ?body2 (let (get ?Ru %0) ?body1))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed and generalized (key doesn't need to be unique) by `sum-sum-vert-fuse-2` and `get-to-sum`
        ////     `(get (sum ?R (sing (unique ?key) ?body1)) ?body2)` -> (`get-to-sum`)
        ////     `(sum (sum ?R (sing (unique ?key) ?body1)) (ifthen (== %1 ?body2u) %0))` -> (`sum-sum-vert-fuse-2`)
        ////     `(sum ?R (let (unique ?key) (let ?body1u (ifthen (== %1 ?body2uu) %0))))` -> (`beta`)
        ////     `(sum ?R (ifthen (== (unique ?key) ?body2u) ?body1))` 
        // rw!("get-sum-vert-fuse-2";  "(get (sum ?R (sing (unique ?key) ?body1)) ?body2)"        => 
        //     { with_shifted_double_up(var("?body2"), var("?body2u"), 0,
        //         "(sum ?R (ifthen (== ?key ?body2u) ?body1))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** sum-range vertical fusion ***/
        rw!("sum-range-1";  "(sum (range ?st ?en) (ifthen (== %0 ?key) ?body))" => 
              { with_shifted_double_up(var("?st"), var("?stu"), 0,
                "(sum (range ?st ?en) (ifthen (== %1 (- ?key (- ?stu 1))) ?body))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        // rw!("sum-range-2";  "(sum (range ?st ?en) (ifthen (== %1 ?key) ?body))"        => 
        //       { with_shifted_double_down(var("?key"), var("?keyd"), 2,
        //         with_shifted_up(var("?st"), var("?stu"), 0,
        //         "(let ?keyd (let (+ %0 (- ?stu 1)) ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     ))} if and(neg(contains_ident(var("?key"), Index(0))), neg(contains_ident(var("?key"), Index(1)))) ),// if and(neg(contains_ident(var("?key"), Index(0))), neg(contains_ident(var("?key"), Index(1)))) ),
        //// REP, generalized by `sum-range-1` and `sum-range-2` and algebraic rules
        // rw!("sum-range-3";  "(sum (range 1 ?en) (ifthen (== %0 ?key) ?body))"        => 
        //       { with_shifted_double_down(var("?key"), var("?keyd"), 2,
        //         "(let ?keyd (let %0 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed by `sum-range-3` and `unique-rm`
        // rw!("sum-range-4";  "(sum (range 1 ?en) (ifthen (== (unique %0) ?key) ?body))"        => 
        //       { with_shifted_double_down(var("?key"), var("?keyd"), 2,
        //         "(let ?keyd (let %0 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** nested sum to merge conversion ***/
        rw!("sum-merge";  "(sum ?R (sum ?S (ifthen (== %2 %0) ?body)))"        => 
            { with_shifted_double_down(var("?S"), var("?Sd"), 2,
                "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        //// REP, already subsumted by sum-merge and unique-rm
        // rw!("sum-merge-2";  "(sum ?R (sum ?S (ifthen (== %0 (unique %2)) ?body)))"        => 
        //     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
        //         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed by sum-merge and eq-comm
        // rw!("sum-merge-3";  "(sum ?R (sum ?S (ifthen (== %0 %2) ?body)))"        => 
        //     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
        //         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        //// REP, already subsumed by sum-merge-3 and eq-comm
        // rw!("sum-merge-4";  "(sum ?R (sum ?S (ifthen (== (unique %2) %0) ?body)))"        => 
        //     { with_shifted_double_down(var("?S"), var("?Sd"), 2,
        //         "(merge ?R ?Sd (let %1 ?body))".parse::<Pattern<SDQL>>().unwrap()
        //     )}),
        /*** merge simplifier ***/
        //// REP, already subsumed by sum-range-1 (it's even a better version)
        // rw!("merge-sum-1";  "(merge (range ?st ?en1) (range ?st ?en2) ?body)"        => 
        //       "(sum (range ?st (binop min ?en1 ?en2)) (let %1 ?body))"
        //     ),
        /*** get and sum conversion ***/
        rw!("get-to-sum";  "(get ?dict ?key)"        => 
            { with_shifted_double_up(var("?key"), var("?keyu"), 0,
                "(sum ?dict (ifthen (== %1 ?keyu) %0))".parse::<Pattern<SDQL>>().unwrap()
            )}),
        rw!("sum-to-get";  "(sum ?R (ifthen (== %1 ?body2) ?body1))" =>
            { with_shifted_up(var("?R"), var("?Ru"), 0,
              with_shifted_double_down(var("?body2"), var("?body2d"), 2,
                "(let ?body2d (let (get ?Ru %0) ?body1))".parse::<Pattern<SDQL>>().unwrap()
            ))} if and(neg(contains_ident(var("?body2"), Index(0))), neg(contains_ident(var("?body2"), Index(1))))),
        rw!("get-range";  "(get (range ?st ?en) ?idx)"        => 
            "(+ ?idx (- ?st 1))"),
        /*** sum simplifier  ***/
        // Can be generalized 
        // 1. similar to get-sum-range
        // rw!("get-sum-range-1";  "(get (sum (range 1 ?en) (sing (unique %0) ?body)) ?idx)"        => 
        //         "(let ?idx (let %0 ?body))"
        // ),
        rw!("sum-sing";    "(sum ?e1 (sing %1 %0))" => "?e1"),
        /*** annotation removal ***/
        rw!("unique-rm";   "(unique ?e)" => "?e"),
    ]
}