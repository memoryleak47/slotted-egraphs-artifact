mod rewrite;
pub use rewrite::*;

mod my_cost;
pub use my_cost::*;

mod analysis;
pub use analysis::*;

mod lang;
pub use lang::*;
use std::fs;

pub use slotted_egraphs::{*, Id};
pub use symbol_table::GlobalSymbol as Symbol;
use memory_stats::memory_stats;

fn get_cost(re: RecExpr<Sdql>) -> usize {
    let mut eg: EGraph<Sdql, SdqlKind> = EGraph::new();
    let id = eg.add_syn_expr(re);
    let cost_func = SdqlCost { egraph: &eg };
    let extractor = Extractor::<_, SdqlCost>::new(&eg, cost_func);
    return extractor.get_best_cost(&id.clone(), &eg);
}

fn thousand_seperator(num: usize) -> String {
    return num.to_string()
    .as_bytes()
    .rchunks(3)
    .rev()
    .map(std::str::from_utf8)
    .collect::<Result<Vec<&str>, _>>()
    .unwrap()
    .join(",");
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let filename = &args[0];
    let e2e = &args[1];
    let coarse = &args[2];
    // let csv_out = &args[1];
    // let csv_f = std::fs::File::create(csv_out).unwrap();
    let folder = "./progs";
    let prog_str = fs::read_to_string(format!("{folder}/{filename}.sexp")).expect("Unable to read file");
    let prog: RecExpr<Sdql> = RecExpr::parse(&prog_str).unwrap();
    let mut eg = EGraph::<Sdql, SdqlKind>::new();
    let rewrites = if coarse == "coarse" {
        sdql_rules_old()
    } else {
        sdql_rules()
    };
    let id1 = eg.add_syn_expr(prog.clone());
    let timeout = 300;
    let MEMORY_LIMIT = 1_500 * 1024 * 1024;
    // let mut timeout = 
    //   if filename.starts_with("mttkrp") {
    //     120
    //   } else if filename.starts_with("batax") {
    //     300
    //   } else { 25 };
    // if e2e != "e2e" {
    //     timeout = 120;
    // }
    let iter_limit = if filename == "batax_1st" {
        13
    } else if filename == "batax_2nd" {
        12
    } else {
        30
    };

    // println!("{}", prog);
    let report = run_eqsat(&mut eg, rewrites, iter_limit, timeout, move |egraph| {
            // Ok(())
            let mut out_of_memory = false;
            // if let Some(it) = r.iterations.last() {
                let memory = memory_stats().expect("could not get current memory usage");
                out_of_memory = memory.physical_mem > MEMORY_LIMIT;
            // }

            if out_of_memory {
                Err("Out of Memory".into())
            } else {
                Ok(())
            }
    });
    let cost_func = SdqlCost { egraph: &eg };
    let extractor = Extractor::<_, SdqlCost>::new(&eg, cost_func);
    let term = extractor.extract(&id1.clone(), &eg);
    let memory = memory_stats().expect("could not get current memory usage");
    // println!("---- {} ----", filename);
    // println!("  Stop reason: {:?}", report.stop_reason);
    // println!("  Iterations: {}", report.iterations);
    // println!("  Egraph size: {} nodes, {} classes", report.egraph_nodes, report.egraph_classes);
    // println!("  Total time: {}", report.total_time);
    // println!("  Physical Memory: {}", memory.physical_mem);
    // println!("  Virtual Memory: {}", memory.virtual_mem);
    println!("{} & slotted & {} & {} & {} & {} & {:.2}", filename, report.iterations, 
        thousand_seperator(report.egraph_nodes), 
        thousand_seperator(report.egraph_classes), 
        if matches!(report.stop_reason, slotted_egraphs::StopReason::Saturated) { "\\yes" } else { "\\no" },
        (memory.physical_mem as f64) / (1024.0 * 1024.0) );
    // may_trace_assert_reaches(lhs, rhs, csv_f, 60);
    if e2e != "e2e" {
        println!("Final Cost: {}", get_cost(term));
    }
}
