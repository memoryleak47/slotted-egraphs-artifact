use egg::{EGraph as EGGEGraph, *};
use crate::sdql::*;
use crate::sdql::EGraph;
use std::collections::HashMap;

pub fn shift_copy(expr: &SDQLRecExpr, up: bool, cutoff: Index, delta: Index) -> SDQLRecExpr {
    let mut result = expr.as_ref().to_owned();
    shift_mut(&mut result, up, cutoff, delta);
    result.into()
}

pub fn shift_mut(expr: &mut [SDQL], up: bool, cutoff: Index, delta: Index) {
    rec(expr, expr.len() - 1, up, cutoff, delta);

    fn rec(expr: &mut [SDQL], ei: usize, up: bool, cutoff: Index, delta: Index) {
        match expr[ei] {
            SDQL::Var(index) => if index >= cutoff {
                let index2 = Index(if up { index.0 + delta.0 } else { index.0 - delta.0 });
                expr[ei] = SDQL::Var(index2);
            }
            SDQL::Lambda(e) => {
                rec(expr, usize::from(e), up, Index(cutoff.0 + 1), delta);
            }
            SDQL::Let([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, Index(cutoff.0 + 1), delta);
            }
            SDQL::Sum([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, Index(cutoff.0 + 2), delta);
            }
            SDQL::Merge([e1, e2, e3]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
                rec(expr, usize::from(e3), up, Index(cutoff.0 + 3), delta);
            }
            SDQL::App([f, e]) => {
                rec(expr, usize::from(f), up, cutoff, delta);
                rec(expr, usize::from(e), up, cutoff, delta);
            }
            SDQL::Binop([f, e1, e2]) => {
                rec(expr, usize::from(f), up, cutoff, delta);
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Add([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Sub([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Mul([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Equality([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::IfThen([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Get([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Sing([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::Range([e1, e2]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
            }
            SDQL::SubArray([e1, e2, e3]) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
                rec(expr, usize::from(e2), up, cutoff, delta);
                rec(expr, usize::from(e3), up, cutoff, delta);
            }
            SDQL::Unique(e1) => {
                rec(expr, usize::from(e1), up, cutoff, delta);
            }
            // SDQL::Length(e1) => {
            //     rec(expr, usize::from(e1), up, cutoff, delta);
            // }
            SDQL::Num(_) | SDQL::Symbol(_) => { (); }
            // _ => ()
        }
    }
}

fn replace(expr: &[SDQL], index: Index, subs: &mut [SDQL]) -> Vec<SDQL> {
    let mut result = vec![];
    rec(&mut result, expr, expr.len() - 1, index, subs);

    fn rec(result: &mut Vec<SDQL>, expr: &[SDQL], ei: usize,
           index: Index, subs: &mut [SDQL]) -> Id {
        match expr[ei] {
            SDQL::Var(index2) =>
                if index == index2 {
                    add_expr(result, subs)
                } else {
                    add(result, SDQL::Var(index2))
                },
            SDQL::Lambda(e) => {
                shift_mut(subs, true, Index(0), Index(1));
                let e2 = rec(result, expr, usize::from(e), Index(index.0 + 1), subs);
                shift_mut(subs, false, Index(0), Index(1));
                add(result, SDQL::Lambda(e2))
            }
            SDQL::Let([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                shift_mut(subs, true, Index(0), Index(1));
                let t2 = rec(result, expr, usize::from(e2), Index(index.0 + 1), subs);
                shift_mut(subs, false, Index(0), Index(1));
                add(result, SDQL::Let([t1, t2]))
            }
            SDQL::Sum([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                shift_mut(subs, true, Index(0), Index(2));
                let t2 = rec(result, expr, usize::from(e2), Index(index.0 + 2), subs);
                shift_mut(subs, false, Index(0), Index(2));
                add(result, SDQL::Sum([t1, t2]))
            }
            SDQL::Merge([e1, e2, e3]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                shift_mut(subs, true, Index(0), Index(3));
                let t3 = rec(result, expr, usize::from(e3), Index(index.0 + 3), subs);
                shift_mut(subs, false, Index(0), Index(3));
                add(result, SDQL::Merge([t1, t2, t3]))
            }
            SDQL::App([f, e]) => {
                let f2 = rec(result, expr, usize::from(f), index, subs);
                let e2 = rec(result, expr, usize::from(e), index, subs);
                add(result, SDQL::App([f2, e2]))
            }
            SDQL::Binop([f, e1, e2]) => {
                let tf = rec(result, expr, usize::from(f), index, subs);
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Binop([tf, t1, t2]))
            }
            // SDQL::Add(_) | SDQL::Sub(_) | SDQL::Mul(_) | SDQL::Get(_) => {
            //     let cs = expr[ei].children();
            //     let t1 = rec(result, expr, usize::from(cs[0]), index, subs);
            //     let t2 = rec(result, expr, usize::from(cs[1]), index, subs);
            //     let res = match expr[ei] {
            //         SDQL::Add(_) => SDQL::Add([t1, t2])
            //         _ => ()
            //     }
            //     add(result, res)
            // }
            SDQL::Add([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Add([t1, t2]))
            }
            SDQL::Sub([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Sub([t1, t2]))
            }
            SDQL::Mul([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Mul([t1, t2]))
            }
            SDQL::Equality([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Equality([t1, t2]))
            }
            SDQL::IfThen([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::IfThen([t1, t2]))
            }
            SDQL::Get([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Get([t1, t2]))
            }
            SDQL::Sing([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Sing([t1, t2]))
            }
            SDQL::Range([e1, e2]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                add(result, SDQL::Range([t1, t2]))
            }
            SDQL::SubArray([e1, e2, e3]) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                let t2 = rec(result, expr, usize::from(e2), index, subs);
                let t3 = rec(result, expr, usize::from(e3), index, subs);
                add(result, SDQL::SubArray([t1, t2, t3]))
            }
            SDQL::Unique(e1) => {
                let t1 = rec(result, expr, usize::from(e1), index, subs);
                add(result, SDQL::Unique(t1))
            }
            // SDQL::Length(e1) => {
            //     let t1 = rec(result, expr, usize::from(e1), index, subs);
            //     add(result, SDQL::Length(t1))
            // }
            SDQL::Symbol(_) | SDQL::Num(_) => {
                add(result, expr[ei].clone())
            }
            // _ => add(result, expr[ei].clone())
        }
    }

    result
}

pub fn beta_reduce(body: &SDQLRecExpr, arg: &SDQLRecExpr) -> SDQLRecExpr {
    let arg2 = &mut arg.as_ref().to_owned();

    shift_mut(arg2, true, Index(0), Index(1));
    let mut body2 = replace(body.as_ref(), Index(0), arg2);
    shift_mut(&mut body2, false, Index(0), Index(1));
    body2.into()
}

pub struct BetaExtractApplier {
    pub body: Var,
    pub subs: Var,
}

impl Applier<SDQL, SDQLAnalysis> for BetaExtractApplier {
    fn apply_one(&self, egraph: &mut EGraph, _eclass: Id, subst: &Subst) -> Vec<Id> {
        let ex_body = &egraph[subst[self.body]].data.beta_extract;
        let ex_subs = &egraph[subst[self.subs]].data.beta_extract;
        let result = beta_reduce(ex_body, ex_subs);
        vec![egraph.add_expr(&result)]
    }
}

pub fn with_shifted_up<A>(var: Var, new_var: Var, cutoff: u32, applier: A) -> Shifted<A>
    where A: Applier<SDQL, SDQLAnalysis> {
    with_delta_shifted_up(var, new_var, cutoff, 1, applier)
}

pub fn with_shifted_double_up<A>(var: Var, new_var: Var, cutoff: u32, applier: A) -> Shifted<A>
    where A: Applier<SDQL, SDQLAnalysis> {
    with_delta_shifted_up(var, new_var, cutoff, 2, applier)
}

pub fn with_delta_shifted_up<A>(var: Var, new_var: Var, cutoff: u32, delta: u32, applier: A) -> Shifted<A>
    where A: Applier<SDQL, SDQLAnalysis> {
    Shifted {
        var,
        new_var,
        up: true,
        cutoff: Index(cutoff),
        delta: Index(delta),
        applier
    }
}

pub fn with_shifted_down<A>(var: Var, new_var: Var, cutoff: u32, applier: A) -> Shifted<A>
    where A: Applier<SDQL, SDQLAnalysis> {
    with_delta_shifted_down(var, new_var, cutoff, 1, applier)
}

pub fn with_shifted_double_down<A>(var: Var, new_var: Var, cutoff: u32, applier: A) -> Shifted<A>
    where A: Applier<SDQL, SDQLAnalysis> {
    with_delta_shifted_down(var, new_var, cutoff, 2, applier)
}

pub fn with_delta_shifted_down<A>(var: Var, new_var: Var, cutoff: u32, delta: u32, applier: A) -> Shifted<A>
    where A: Applier<SDQL, SDQLAnalysis> {
    Shifted {
        var,
        new_var,
        up: false,
        cutoff: Index(cutoff),
        delta: Index(delta),
        applier
    }
}

pub struct Shifted<A> {
    var: Var,
    new_var: Var,
    up: bool,
    cutoff: Index,
    delta: Index,
    applier: A,
}

impl<A> Applier<SDQL, SDQLAnalysis> for Shifted<A> where A: Applier<SDQL, SDQLAnalysis> {
    fn apply_one(&self, egraph: &mut EGraph, eclass: Id, subst: &Subst) -> Vec<Id> {
        let extract = &egraph[subst[self.var]].data.beta_extract;
        let shifted = shift_copy(extract, self.up, self.cutoff, self.delta);
        let mut subst = subst.clone();
        subst.insert(self.new_var, egraph.add_expr(&shifted));
        self.applier.apply_one(egraph, eclass, &subst)
    }
}

#[cfg(test)]
mod tests {
    fn check(body: &str, arg: &str, res: &str) {
        let b = &body.parse().unwrap();
        let a = &arg.parse().unwrap();
        let r = res.parse().unwrap();
        assert_eq!(super::beta_reduce(b, a), r);
    }

    #[test]
    fn beta_reduce() {
        // (λ. (λ. ((λ. (0 1)) (0 1)))) --> (λ. (λ. ((0 1) 0)))
        // (λ. (0 1)) (0 1) --> (0 1) 0
        check("(apply %0 %1)", "(apply %0 %1)", "(apply (apply %0 %1) %0)");
        // r1 = (apply (lambda (apply "%6" (apply "%5" "%0"))) "%0")
        // r2 = (apply (lambda (apply "%6" r1)) "%0")
        // r3 = (apply (lambda (apply "%6" r2)) %0)
        // (apply map (lambda (apply "%6" r3)))
        // --> (apply map (lambda (apply "%6" (apply "%5" (apply "%4" (apply "%3" (apply "%2" "%0")))))))
        check("(apply %6 (apply %5 %0))", "%0", "(apply %5 (apply %4 %0))");
        check("(apply %6 (apply %5 (apply %4 %0)))", "%0", "(apply %5 (apply %4 (apply %3 %0)))");
        check("(apply %6 (apply %5 (apply %4 (apply %3 %0))))", "%0", "(apply %5 (apply %4 (apply %3 (apply %2 %0))))");
    }
}