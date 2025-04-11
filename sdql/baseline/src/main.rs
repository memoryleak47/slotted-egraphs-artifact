use egg::*;
use instant::{Duration};
// use std::convert::TryFrom;
// use symbolic_expressions::Sexp;
use std::fs;
use std::env;

// mod sdql2;
// use crate::sdql2::*;
mod sdql;
mod sdqlsubstitute;
mod sdqlrules;
use crate::sdql::*;
use crate::sdqlsubstitute::*;
use crate::sdqlrules::*;

use memory_stats::memory_stats;

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

// usage:
// run batax_v0 e2e coarse
// run batax_v0 ind fine
fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];
    let e2e = &args[2];
    let coarse = &args[3];
    // println!("{:?}", args[1]);
    let MEMORY_LIMIT = 1_500 * 1024 * 1024;

    let mut runner = Runner::default()
        .with_iter_limit(4000)
        .with_node_limit(10_000_000)
        .with_time_limit(Duration::from_secs(1200));

    runner = runner.with_hook(move |r| {
            let mut out_of_memory = false;
            if let Some(it) = r.iterations.last() {
                let memory = memory_stats().expect("could not get current memory usage");
                out_of_memory = memory.physical_mem > MEMORY_LIMIT;
            }

            if out_of_memory {
                Err("Out of Memory".into())
            } else {
                Ok(())
            }
        })
        ;
        
        
    
    let input_file = "progs/".to_owned() + filename + ".sexp";
    let output_file = "progs/".to_owned() + filename + "_esat.sexp";
    let start = fs::read_to_string(input_file).expect("Unable to read file");

    let sexp = symbolic_expressions::parser::parse_str(&start.to_string()).unwrap();
    let sexp2 = sexp_to_nameless(&sexp);
    let converted = sexp2.to_string();
    let sexp3 = sexp_to_named(&sexp2, 0);
    // println!("init:\n{}\nconverted:\n{}", sexp, converted);
    // println!("init recovered:\n{}", sexp3);
    

    let start_expr = converted.parse().unwrap();

    runner = runner.with_expr(&start_expr);
    runner = if coarse == "coarse" {
        runner.run(&rules_old())
    } else {
        runner.run(&rules())
    };

    // println!("{}", filename);
    // runner.print_report();
    let cost_func = SDQLCost { egraph: &runner.egraph };
    let mut extractor = Extractor::new(&runner.egraph, cost_func);
    let (best_cost, best) = extractor.find_best(runner.roots[0]);
    let memory = memory_stats().expect("could not get current memory usage");
    println!("{} & egg & {} & {} & {} & {} & {:.2}", filename, runner.iterations.len(), 
        thousand_seperator(runner.egraph.total_number_of_nodes()), 
        thousand_seperator(runner.egraph.number_of_classes()),
        if matches!(runner.stop_reason.as_ref().unwrap(), egg::StopReason::Saturated) {"\\yes"} else {"\\no"},
        (memory.physical_mem as f64) / (1024.0 * 1024.0) );
    let out_str = sdql_print(best, false);
    if e2e == "ind" {
        let bestcost_file = "progs/".to_owned() + filename + "_bestcost.txt";
        let bestcost_str = fs::read_to_string(bestcost_file).expect("Unable to read cost file");
        let actual_best_cost: usize = bestcost_str.parse::<usize>().unwrap();
        if actual_best_cost == best_cost {
            let mut iter_best_found = 0;

            let mut runner2 = Runner::default()
                .with_iter_limit(30)
                .with_node_limit(10_000_000)
                .with_time_limit(Duration::from_secs(1200));

            runner2 = runner2.with_hook(move |r| {
                    let cost_func = SDQLCost { egraph: &r.egraph };
                    let mut extractor = Extractor::new(&r.egraph, cost_func);
                    let (best_cost2, _) = extractor.find_best(r.roots[0]);
                    if best_cost2 == actual_best_cost {
                        iter_best_found = r.iterations.len();
                        println!("Best cost found in iteration {}!", iter_best_found);
                        Err("Best cost found".into())
                    } else {
                        Ok(())
                    }
                });
            runner2 = runner2.with_expr(&start_expr);
            runner2 = if coarse == "coarse" {
                runner2.run(&rules_old())
            } else {
                runner2.run(&rules())
            };
        } else {
            println!("Best cost not found!");
        }
    }
    fs::write(output_file, out_str).expect("Unable to write file");
}
