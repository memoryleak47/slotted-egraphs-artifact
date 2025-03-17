#![allow(unused)]
#![allow(non_snake_case)]

use crate::*;

#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub enum Var {
    F(Slot, Slot),
}

impl Language for Var {
    fn all_slot_occurences_mut(&mut self) -> Vec<&mut Slot> {
        match self {
            Var::F(x, y) => vec![x, y],
        }
    }

    fn public_slot_occurences_mut(&mut self) -> Vec<&mut Slot> {
        match self {
            Var::F(x, y) => vec![x, y],
        }
    }

    fn applied_id_occurences_mut(&mut self) -> Vec<&mut AppliedId> {
        vec![]
    }

    fn to_op(&self) -> (String, Vec<Child>) {
        match self.clone() {
            Var::F(x, y) => (String::from("f"), vec![Child::Slot(x), Child::Slot(y)]),
        }
    }

    fn from_op(op: &str, children: Vec<Child>) -> Option<Self> {
        match (op, &*children) {
            ("f", [Child::Slot(x), Child::Slot(y)]) => Some(Var::F(*x, *y)),
            _ => None,
        }
    }
}

#[test]
fn xy_eq_yz_causes_redundancy() {
    let mut eg = EGraph::<Var>::new();
    let a = eg.add_expr(RecExpr::parse("(f $0 $1)").unwrap());
    let b = eg.add_expr(RecExpr::parse("(f $1 $2)").unwrap());
    eg.union(&a, &b);
    eg.dump();
    let ids = eg.ids();
    assert_eq!(ids.len(), 1);
    let id = ids[0];
    assert!(eg.slots(id).is_empty());
}
