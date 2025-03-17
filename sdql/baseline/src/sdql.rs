use egg::*;
// use std::fmt::{self, Debug, Display};
use symbolic_expressions::Sexp;
use std::cmp::Ordering;
use std::collections::HashSet;
use std::collections::HashMap;

pub type EGraph = egg::EGraph<SDQL, SDQLAnalysis>;

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone, Hash, Copy)]
pub struct Index(pub u32);

impl std::str::FromStr for Index {
    type Err = Option<std::num::ParseIntError>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if s.starts_with("%") {
            s["%".len()..].parse().map(Index).map_err(Some)
        } else {
            Err(None)
        }
    }
}

impl std::fmt::Display for Index {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "%{}", self.0)
    }
}

// Define the SDQL language
//
// Note:
// For the merge construct, the order in DB is changed as follows:
//      Original:    merge k1 k2 v1 R1 R2 body
//      DB:          merge k1 v1 k2 R1 R2 body
// This is required for simplifying rewrite rules.
define_language! {
    pub enum SDQL {
        Var(Index),
        Num(i32),
        // "var" = Var(Id),
        "*" = Mul([Id; 2]),
        "+" = Add([Id; 2]),
        "-" = Sub([Id; 2]),
        "==" = Equality([Id; 2]),
        "let" = Let([Id; 2]),
        "sing" = Sing([Id; 2]),
        "ifthen" = IfThen([Id; 2]),
        "get" = Get([Id; 2]),
        "sum" = Sum([Id; 2]),
        "merge" = Merge([Id; 3]),
        "range" = Range([Id; 2]),
        "subarray" = SubArray([Id; 3]),
        // "length" = Length(Id),
        "apply" = App([Id; 2]),
        "binop" = Binop([Id; 3]),
        "lambda" = Lambda(Id),
        // "S" = SuccV(Id),
        // "SC" = SuccCut([Id; 3]), // SC(increase, cutoff, exp)
        "unique" = Unique(Id),
        // "O" = ZeroV([Id; 0]),
        Symbol(Symbol),
    }
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone, Hash, Copy)]
pub enum SDQLType {
    Vector,
    Dict,
    Scalar, 
    Bool
}

#[derive(Default, Debug)]
pub struct SDQLData {
    pub free: HashSet<Index>,
    pub beta_extract: SDQLRecExpr,
    pub kind: HashSet<SDQLType>
}


pub type SDQLRecExpr = RecExpr<SDQL>;

#[derive(Default)]
pub struct SDQLAnalysis;

impl Analysis<SDQL> for SDQLAnalysis {
    type Data = SDQLData;

    fn merge(&self, to: &mut SDQLData, from: SDQLData) -> Option<Ordering> {
        let before_len = to.free.len();
        to.free.extend(from.free);
        to.kind.extend(from.kind);
        let mut did_change = before_len != to.free.len();
        if !from.beta_extract.as_ref().is_empty() &&
            (to.beta_extract.as_ref().is_empty() ||
                to.beta_extract.as_ref().len() > from.beta_extract.as_ref().len()) {
            to.beta_extract = from.beta_extract;
            did_change = true;
        }
        if did_change { None } else { Some(Ordering::Greater) }
    }

    fn make(egraph: &EGraph, enode: &SDQL) -> SDQLData {
        let mut free = HashSet::default();
        match enode {
            SDQL::Var(v) => {
                free.insert(*v);
            }
            SDQL::Lambda(a) => {
                enode.for_each(|c| free.extend(
                    egraph[c].data.free.iter().cloned()
                        .filter(|&idx| idx != Index(0))
                        .map(|idx| Index(idx.0 - 1))));
            }
            SDQL::Let([e1, e2]) => {
                free.extend(egraph[*e1].data.free.iter().cloned());
                free.extend(egraph[*e2].data.free.iter().cloned()
                        .filter(|&idx| idx != Index(0))
                        .map(|idx| Index(idx.0 - 1)));
            }
            SDQL::Sum([e1, e2]) => {
                free.extend(egraph[*e1].data.free.iter().cloned());
                free.extend(egraph[*e2].data.free.iter().cloned()
                        .filter(|&idx| idx.0 > 1)
                        .map(|idx| Index(idx.0 - 2)));
            }
            SDQL::Merge([e1, e2, e3]) => {
                free.extend(egraph[*e1].data.free.iter().cloned());
                free.extend(egraph[*e2].data.free.iter().cloned());
                free.extend(egraph[*e3].data.free.iter().cloned()
                        .filter(|&idx| idx.0 > 2)
                        .map(|idx| Index(idx.0 - 3)));
            }
            _ => {
                enode.for_each(|c| free.extend(&egraph[c].data.free));
            }
        }
        let empty = enode.any(|id| {
            egraph[id].data.beta_extract.as_ref().is_empty()
        });
        let beta_extract = if empty {
            vec![].into()
        } else {
            enode.to_recexpr(|id| egraph[id].data.beta_extract.as_ref())
        };
        let mut kind = HashSet::default();
        match enode {
            SDQL::SubArray(_) | SDQL::Range(_) => {
                kind.insert(SDQLType::Vector);
            }
            SDQL::Equality(_) => {
                kind.insert(SDQLType::Bool);
            }
            SDQL::Num(_) => {
                kind.insert(SDQLType::Scalar);
            }
            SDQL::Sing(_) => {
                kind.insert(SDQLType::Dict);
            }
            // SDQL::Sum([_, body]) => {
            //     kind.extend(egraph[*body].data.kind.clone());
            // }
            // SDQL::Let([_, body]) => {
            //     kind.extend(egraph[*body].data.kind.clone());
            // }
            // SDQL::Merge([_, _, body]) => {
            //     kind.extend(egraph[*body].data.kind.clone());
            // }
            _ => {
            }
        }
        // kind.insert(enode.clone());
        SDQLData { free, beta_extract, kind }
    }
}

pub fn add(to: &mut Vec<SDQL>, e: SDQL) -> Id {
    to.push(e);
    Id::from(to.len() - 1)
}

pub fn add_expr(to: &mut Vec<SDQL>, e: &[SDQL]) -> Id {
    let offset = to.len();
    to.extend(e.iter().map(|n| n.clone().map_children(|id| {
        Id::from(usize::from(id) + offset)
    })));
    Id::from(to.len() - 1)
}


pub struct SDQLCost<'a> {
    pub egraph: &'a EGraph,
}

impl<'a> CostFunction<SDQL> for SDQLCost<'a> {
    type Cost = usize;
    fn cost<C>(&mut self, enode: &SDQL, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        let num_access = 1;
        let var_access = 5;
        let sum_dict_coef = 1000;
        let sum_vector_coef = 1000 / 5;
        let let_coef = 10;
        let infinity = usize::MAX / 1000;
        let op_cost = match enode {
                    SDQL::Get(_) => 20,
                    SDQL::Let([rng, _]) => let_coef,
                    SDQL::Sing(_) => 50,
                    SDQL::App(_) |
                    SDQL::Binop(_) => infinity,
                    SDQL::Var(_) => var_access,
                    SDQL::Num(_) => num_access,
                    SDQL::Unique(_) => 0,
                    _ => 1
                };
        let is_infinity = enode.any(|id| costs(id) >= infinity);
        if is_infinity || op_cost == infinity {
            return infinity;
        }
        match enode {
            SDQL::Sum([range, body]) =>
                costs(*range) + 
                    (if(self.egraph[*range].data.kind.contains(&SDQLType::Vector)) {  
                        sum_vector_coef 
                    } else { 
                        sum_dict_coef 
                    }) * (1 + costs(*body))
                ,
            SDQL::Merge([range1, range2, body]) =>
                costs(*range1) + costs(*range2) + (
                if(self.egraph[*range1].data.kind.contains(&SDQLType::Vector) && self.egraph[*range2].data.kind.contains(&SDQLType::Vector)) {
                    sum_vector_coef
                } else {
                    sum_dict_coef
                }) * (1 + costs(*body)),
            SDQL::Mul([e1, e2]) if self.egraph[*e1].data.kind.contains(&SDQLType::Bool) || self.egraph[*e2].data.kind.contains(&SDQLType::Bool) =>
                infinity,
            SDQL::Mul([e1, e2]) if self.egraph[*e1].data.kind.contains(&SDQLType::Dict) || self.egraph[*e2].data.kind.contains(&SDQLType::Dict) =>
                enode.fold(sum_dict_coef, |sum, id| sum + costs(id)),
            _ =>
                enode.fold(op_cost, |sum, id| sum + costs(id))
        }
    }
}

pub fn sdql_print(obj: SDQLRecExpr, debug: bool) -> String {
    let n = obj.as_ref().len() - 1;
    let sexp = sdql_to_sexp(obj, n);
    let sexp2 = sexp_to_named(&sexp, 0);
    if debug {
        println!("{}", sexp.to_string());
        println!("{}", sexp2.to_string());
    }
    return sexp2.to_string(); 
    // println!("{}", sexp_to_nameless(&sexp2).to_string());
}

// pub fn format(obj: SDQLRecExpr, f: &mut fmt::Formatter) -> fmt::Result {
//     if obj.as_ref().is_empty() {
//         write!(f, "()")
//     } else {
//         let n = obj.as_ref().len() - 1;
//         let s = sdql_to_sexp(obj, n).to_string();
//         write!(f, "{}", s)
//     }
// }

pub fn sdql_to_sexp(obj: SDQLRecExpr, i: usize) -> Sexp {
    let node = &obj.as_ref()[i];
    let op = Sexp::String(node.to_string());
    if node.is_leaf() {
        op
    } else {
        let mut vec = vec![op];
        node.for_each(|id| vec.push(sdql_to_sexp(obj.clone(), id.into())));
        Sexp::List(vec)
    }
}

pub fn sexp_to_nameless(sexp: &Sexp) -> Sexp {
    let mut ht = HashMap::new();
    _sexp_to_nameless(sexp, &mut ht, 0)
}

fn _sexp_var_nameless(i: usize) -> Sexp {
    Sexp::String(format!("%{}", i))
    // if i == 0 {
    //     Sexp::String("O".to_string())
    // } else {
    //     Sexp::List([Sexp::String("S".to_string()),_sexp_var_nameless(i-1)].to_vec())
    // }
}

fn _sexp_to_nameless(sexp: &Sexp, ht: &mut HashMap<String, usize>, d: usize) -> Sexp {
    match sexp {
        Sexp::Empty => Sexp::Empty,
        Sexp::String(s) => 
            Sexp::String(s.to_string()),
        Sexp::List(list) => match &list[0] {
            Sexp::Empty => unreachable!("Cannot be in head position"),
            Sexp::List(l) => unreachable!("Found a list in the head position: {:?}", l),
            Sexp::String(s) if s == "var" => {
                if let Sexp::String(vname) = &list[1] {
                    if let Some(dep) = ht.get(&vname.to_string()) {
                        // Sexp::String(format!("depth_{}_{}", d - dep, dep).to_string())
                        _sexp_var_nameless(d - dep)
                    } else {
                        unreachable!(format!("Variable {} not in scope!", vname.to_string()))
                    }
                } else {
                    unreachable!(format!("wrong syntax for variables: `var {}`!", &list[1]))
                }
            }
            Sexp::String(s) => {
                let mut vec = vec![Sexp::String(s.to_string())];
                // let nl = list[1..].iter().map(|id| sexp_to_named(id)).collect();
                if s.to_string() == "let" {
                    vec.push(_sexp_to_nameless(&list[2], ht, d));
                    if let Sexp::String(vname) = &list[1] {
                        ht.insert(vname.to_string(), d+1);
                        // println!("var: {}", vname);
                        // println!("ht: {:?}", ht);
                    }
                    vec.push(_sexp_to_nameless(&list[3], ht, d+1));
                } else if s.to_string() == "sum" {
                    vec.push(_sexp_to_nameless(&list[3], ht, d));
                    if let (Sexp::String(vname1), Sexp::String(vname2)) = (&list[1], &list[2]) {
                        ht.insert(vname1.to_string(), d+1);
                        ht.insert(vname2.to_string(), d+2);
                        // println!("vars: {}, {}", vname1, vname2);
                        // println!("ht: {:?}", ht);
                    }
                    vec.push(_sexp_to_nameless(&list[4], ht, d+2));
                } else if s.to_string() == "merge" {
                    vec.push(_sexp_to_nameless(&list[4], ht, d));
                    vec.push(_sexp_to_nameless(&list[5], ht, d));
                    if let (Sexp::String(key1), Sexp::String(key2), Sexp::String(val1)) = (&list[1], &list[2], &list[3]) {
                        ht.insert(key1.to_string(), d+1);
                        ht.insert(val1.to_string(), d+2);
                        ht.insert(key2.to_string(), d+3);
                        // println!("vars: {}, {}", vname1, vname2);
                        // println!("ht: {:?}", ht);
                    }
                    vec.push(_sexp_to_nameless(&list[6], ht, d+3));
                } else if s.to_string() == "lambda" {
                    if let Sexp::String(vname) = &list[1] {
                        ht.insert(vname.to_string(), d+1);
                        // println!("var: {}", vname);
                        // println!("ht: {:?}", ht);
                    }
                    vec.push(_sexp_to_nameless(&list[2], ht, d+1));
                } else {
                    list[1..].iter().for_each(|id| vec.push(_sexp_to_nameless(id, ht, d)));
                }
                Sexp::List(vec)
            }
        }
    }
}

fn var_to_sexp(idx: usize) -> Sexp {
    Sexp::String(format!("var_{:02}", idx).to_string())
}

pub fn sexp_to_named(sexp: &Sexp, i: usize) -> Sexp {
    match sexp {
        Sexp::Empty => Sexp::Empty,
        // Sexp::String(s) => if s == "O" {
        //     // Sexp::String("var".to_string())
        //     let v = var_to_sexp(i);
        //     Sexp::List([Sexp::String("var".to_string()),v].to_vec())
        // } else {
        //     Sexp::String(s.to_string())
        // },
        Sexp::String(s) => if s.starts_with("%") {
            // s["%".len()..].parse().map(Index).map_err(Some)
            let idx = i - &s["%".len()..].parse::<usize>().unwrap();
            let v = var_to_sexp(idx);
            Sexp::List([Sexp::String("var".to_string()),v].to_vec())
        } else {
            Sexp::String(s.to_string())
        }
        Sexp::List(list) => match &list[0] {
            Sexp::Empty => unreachable!("Cannot be in head position"),
            Sexp::List(l) => unreachable!("Found a list in the head position: {:?}", l),
            // Sexp::String(s) if s == "O" => Sexp::List(vec![Sexp::String(format!("var{}", i).to_string())]),
            // Sexp::String(s) if s == "S" => {
            //     sexp_to_named(&list[1], i-1)
            // }
            Sexp::String(s) => {
                let mut vec = vec![Sexp::String(s.to_string())];
                // let nl = list[1..].iter().map(|id| sexp_to_named(id)).collect();
                if s.to_string() == "let" {
                    vec.push(var_to_sexp(i+1));
                    vec.push(sexp_to_named(&list[1], i));
                    vec.push(sexp_to_named(&list[2], i+1));
                    // list[1..].iter().for_each(|id| vec.push(sexp_to_named(id, i)));
                // else if(s.to_string() == "let")
                }
                else if s.to_string() == "lambda" {
                    vec.push(var_to_sexp(i+1));
                    vec.push(sexp_to_named(&list[1], i+1));
                    // list[1..].iter().for_each(|id| vec.push(sexp_to_named(id, i)));
                // else if(s.to_string() == "let")
                }
                else if s.to_string() == "sum" {
                    vec.push(var_to_sexp(i+1));
                    vec.push(var_to_sexp(i+2));
                    vec.push(sexp_to_named(&list[1], i));
                    vec.push(sexp_to_named(&list[2], i+2));
                }
                else if s.to_string() == "merge" {
                    vec.push(var_to_sexp(i+1));
                    vec.push(var_to_sexp(i+3));
                    vec.push(var_to_sexp(i+2));
                    vec.push(sexp_to_named(&list[1], i));
                    vec.push(sexp_to_named(&list[2], i));
                    vec.push(sexp_to_named(&list[3], i+3));
                }
                else {
                    list[1..].iter().for_each(|id| vec.push(sexp_to_named(id, i)));
                }
                // vec.append(nl);
                Sexp::List(vec)
            },
            // _ => Sexp::List(list)
        },
    }
}