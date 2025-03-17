use crate::*;

#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub enum Sdql {
    Lam(Slot, AppliedId),
    Var(Slot),
    Sing(AppliedId, AppliedId),
    Add(AppliedId, AppliedId),
    Mult(AppliedId, AppliedId),
    Sub(AppliedId, AppliedId),
    Equality(AppliedId, AppliedId),
    Get(AppliedId, AppliedId),
    Range(AppliedId, AppliedId),
    App(AppliedId, AppliedId),
    IfThen(AppliedId, AppliedId),
    Binop(AppliedId, AppliedId, AppliedId),
    SubArray(AppliedId, AppliedId, AppliedId),
    Unique(AppliedId),
    Sum(Slot, Slot, /*range: */AppliedId, /*body: */ AppliedId),
    Merge(Slot, Slot, Slot, /*range1: */AppliedId, /*range2: */AppliedId, /*body: */ AppliedId),
    Let(Slot, AppliedId, AppliedId),
    Num(u32),
    Symbol(Symbol),
}

impl Language for Sdql {
    fn all_slot_occurences_mut(&mut self) -> Vec<&mut Slot> {
        let mut out = Vec::new();
        match self {
            Sdql::Lam(x, b) => {
                out.push(x);
                out.extend(b.slots_mut());
            }
            Sdql::Var(x) => {
                out.push(x);
            }
            Sdql::Sing(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Add(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Mult(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Sub(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Equality(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Get(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Range(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::App(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::IfThen(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Binop(x, y, z) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
                out.extend(z.slots_mut());
            }
            Sdql::SubArray(x, y, z) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
                out.extend(z.slots_mut());
            }
            Sdql::Unique(x) => {
                out.extend(x.slots_mut());
            }
            Sdql::Sum(k, v, r, b) => {
                out.push(k);
                out.push(v);
                out.extend(r.slots_mut());
                out.extend(b.slots_mut());
            }
            Sdql::Merge(k1, k2, v, r1, r2, b) => {
                out.push(k1);
                out.push(k2);
                out.push(v);
                out.extend(r1.slots_mut());
                out.extend(r2.slots_mut());
                out.extend(b.slots_mut());
            }
            Sdql::Let(x, e1, e2) => {
                out.push(x);
                out.extend(e1.slots_mut());
                out.extend(e2.slots_mut());
            }
            Sdql::Num(_) => {}
            Sdql::Symbol(_) => {}
        }
        out
    }

    fn public_slot_occurences_mut(&mut self) -> Vec<&mut Slot> {
        let mut out = Vec::new();
        match self {
            Sdql::Lam(x, b) => {
                out.extend(b.slots_mut().into_iter().filter(|y| *y != x));

            }
            Sdql::Var(x) => {
                out.push(x);
            }
            Sdql::Sing(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Add(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Mult(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Sub(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Equality(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Get(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Range(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::App(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::IfThen(x, y) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
            }
            Sdql::Binop(x, y, z) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
                out.extend(z.slots_mut());
            }
            Sdql::SubArray(x, y, z) => {
                out.extend(x.slots_mut());
                out.extend(y.slots_mut());
                out.extend(z.slots_mut());
            }
            Sdql::Unique(x) => {
                out.extend(x.slots_mut());
            }
            Sdql::Sum(k, v, r, b) => {
                out.extend(b.slots_mut().into_iter().filter(|y| *y != k && *y != v));
                out.extend(r.slots_mut());
            }
            Sdql::Merge(k1, k2, v, r1, r2, b) => {
                out.extend(b.slots_mut().into_iter().filter(|y| *y != k1 && *y != k2 && *y != v));
                out.extend(r1.slots_mut());
                out.extend(r2.slots_mut());
            }
            Sdql::Let(x, e1, e2) => {
                out.extend(e2.slots_mut().into_iter().filter(|y| *y != x));
                out.extend(e1.slots_mut());
            }
            Sdql::Num(_) => {}
            Sdql::Symbol(_) => {}
        }
        out
    }

    fn applied_id_occurences_mut(&mut self) -> Vec<&mut AppliedId> {
        match self {
            Sdql::Lam(_, y) => vec![y],
            Sdql::Var(_) => vec![],
            Sdql::Sing(x, y) => vec![x, y],
            Sdql::Add(x, y) => vec![x, y],
            Sdql::Mult(x, y) => vec![x, y],
            Sdql::Sub(x, y) => vec![x, y],
            Sdql::Equality(x, y) => vec![x, y],
            Sdql::Get(x, y) => vec![x, y],
            Sdql::Range(x, y) => vec![x, y],
            Sdql::App(x, y) => vec![x, y],
            Sdql::IfThen(x, y) => vec![x, y],
            Sdql::Binop(x, y, z) => vec![x, y, z],
            Sdql::SubArray(x, y, z) => vec![x, y, z],
            Sdql::Unique(x) => vec![x],
            Sdql::Sum(_, _, r, b) => vec![r, b],
            Sdql::Merge(_, _, _, r1, r2, b) => vec![r1, r2, b],
            Sdql::Let(_, e1, e2) => vec![e1, e2],
            Sdql::Num(_) => vec![],
            Sdql::Symbol(_) => vec![],
        }
    }

    fn to_op(&self) -> (String, Vec<Child>) {
        match self.clone() {
            Sdql::Lam(s, a) => (String::from("lambda"), vec![Child::Slot(s), Child::AppliedId(a)]),
            Sdql::Var(s) => (String::from("var"), vec![Child::Slot(s)]),
            Sdql::Sing(x, y) => (String::from("sing"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Add(x, y) => (String::from("+"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Mult(x, y) => (String::from("*"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Sub(x, y) => (String::from("-"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Equality(x, y) => (String::from("eq"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Get(x, y) => (String::from("get"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Range(x, y) => (String::from("range"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::App(x, y) => (String::from("apply"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::IfThen(x, y) => (String::from("ifthen"), vec![Child::AppliedId(x), Child::AppliedId(y)]),
            Sdql::Binop(x, y, z) => (String::from("binop"), vec![Child::AppliedId(x), Child::AppliedId(y), Child::AppliedId(z)]),
            Sdql::SubArray(x, y, z) => (String::from("subarray"), vec![Child::AppliedId(x), Child::AppliedId(y), Child::AppliedId(z)]),
            Sdql::Unique(x) => (String::from("unique"), vec![Child::AppliedId(x)]),
            Sdql::Sum(k, v, r, b) => (String::from("sum"), vec![Child::Slot(k), Child::Slot(v), Child::AppliedId(r), Child::AppliedId(b)]),
            Sdql::Merge(k1, k2, v, r1, r2, b) => (String::from("merge"), vec![Child::Slot(k1), Child::Slot(k2), Child::Slot(v), Child::AppliedId(r1), Child::AppliedId(r2), Child::AppliedId(b)]),
            Sdql::Let(x, e1, e2) => (String::from("let"), vec![Child::Slot(x), Child::AppliedId(e1), Child::AppliedId(e2)]),
            Sdql::Num(n) => (format!("{}", n), vec![]),
            Sdql::Symbol(s) => (format!("{}", s), vec![]),
        }
    }

    fn from_op(op: &str, children: Vec<Child>) -> Option<Self> {
        match (op, &*children) {
            ("lambda", [Child::Slot(s), Child::AppliedId(a)]) => Some(Sdql::Lam(*s, a.clone())),
            ("var", [Child::Slot(s)]) => Some(Sdql::Var(*s)),
            ("sing", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Sing(x.clone(), y.clone())),
            ("+", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Add(x.clone(), y.clone())),
            ("*", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Mult(x.clone(), y.clone())),
            ("-", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Sub(x.clone(), y.clone())),
            ("eq", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Equality(x.clone(), y.clone())),
            ("get", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Get(x.clone(), y.clone())),
            ("range", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::Range(x.clone(), y.clone())),
            ("apply", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::App(x.clone(), y.clone())),
            ("ifthen", [Child::AppliedId(x), Child::AppliedId(y)]) => Some(Sdql::IfThen(x.clone(), y.clone())),
            ("binop", [Child::AppliedId(x), Child::AppliedId(y), Child::AppliedId(z)]) => Some(Sdql::Binop(x.clone(), y.clone(), z.clone())),
            ("subarray", [Child::AppliedId(x), Child::AppliedId(y), Child::AppliedId(z)]) => Some(Sdql::SubArray(x.clone(), y.clone(), z.clone())),
            ("unique", [Child::AppliedId(x)]) => Some(Sdql::Unique(x.clone())),
            ("sum", [Child::Slot(k), Child::Slot(v), Child::AppliedId(r), Child::AppliedId(b)]) => Some(Sdql::Sum(*k, *v, r.clone(), b.clone())),
            ("merge", [Child::Slot(k1), Child::Slot(k2), Child::Slot(v), Child::AppliedId(r1), Child::AppliedId(r2), Child::AppliedId(b)]) => Some(Sdql::Merge(*k1, *k2, *v, r1.clone(), r2.clone(), b.clone())),
            ("let", [Child::Slot(x), Child::AppliedId(e1), Child::AppliedId(e2)]) => Some(Sdql::Let(*x, e1.clone(), e2.clone())),
            (op, []) => {
                if let Ok(u) = op.parse::<u32>() {
                    Some(Sdql::Num(u))
                } else {
                    let s: Symbol = op.parse().ok()?;
                    Some(Sdql::Symbol(s))
                }
            },
            _ => None,
        }
    }
}
