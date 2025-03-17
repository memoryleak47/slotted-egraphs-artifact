use crate::*;

pub struct LambdaRealLambda;

impl Realization for LambdaRealLambda {
    fn step(eg: &mut EGraph<Lambda>) {
        rewrite_let(eg);
    }
}

unpack_tests!(LambdaRealLambda);


pub fn rewrite_let(eg: &mut EGraph<Lambda>) {
    apply_rewrites(eg, &[
        beta(),
        my_let_unused(),
        let_var_same(),
        let_app(),
        let_lam_diff(),
    ]);
}

fn beta() -> Rewrite<Lambda> {
    let pat = "(app (lam $1 ?b) ?t)";
    let outpat = "(let $1 ?t ?b)";
    Rewrite::new("beta", pat, outpat)
}

fn my_let_unused() -> Rewrite<Lambda> {
    let pat = "(let $1 ?t ?b)";
    let outpat = "?b";
    Rewrite::new_if("my-let-unused", pat, outpat, |subst, _| {
        !subst["b"].slots().contains(&Slot::numeric(1))
    })
}

fn let_var_same() -> Rewrite<Lambda> {
    let pat = "(let $1 ?e (var $1))";
    let outpat = "?e";
    Rewrite::new("let-var-same", pat, outpat)
}

fn let_app() -> Rewrite<Lambda> {
    let pat = "(let $1 ?e (app ?a ?b))";
    let outpat = "(app (let $1 ?e ?a) (let $1 ?e ?b))";
    Rewrite::new_if("let-app", pat, outpat, |subst, _| {
        subst["a"].slots().contains(&Slot::numeric(1)) || subst["b"].slots().contains(&Slot::numeric(1))
    })
}

fn let_lam_diff() -> Rewrite<Lambda> {
    let pat = "(let $1 ?e (lam $2 ?b))";
    let outpat = "(lam $2 (let $1 ?e ?b))";
    Rewrite::new_if("let-lam-diff", pat, outpat, |subst, _| {
        subst["b"].slots().contains(&Slot::numeric(1))
    })
}
