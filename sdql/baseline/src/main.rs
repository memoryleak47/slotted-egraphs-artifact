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

fn main() {
    let args: Vec<String> = env::args().collect();
    // println!("{:?}", args[1]);
    //// E2E
    // let MEMORY_LIMIT = 1_500 * 1024 * 1024;
    //// MTTKRP individual
    let MEMORY_LIMIT = 3_000 * 1024 * 1024;

    let mut runner = Runner::default()
        // .with_explanations_enabled()
        //// MTTKRP individual
        // .with_iter_limit(4000)
        // .with_node_limit(10_000_000)
        // .with_time_limit(Duration::from_secs(1200))
        //// E2E
        .with_iter_limit(4_000)
        .with_node_limit(1_000_000)
        .with_time_limit(Duration::from_secs(120))
        .with_hook(move |r| {
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
    let filename = if args.len() >= 2 { &args[1] } else { "batax_v0" };
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
    runner = runner.run(&rules_old());
    // runner = runner.run(&rules());

    println!("{}", filename);
    runner.print_report();
    let cost_func = SDQLCost { egraph: &runner.egraph };
    let mut extractor = Extractor::new(&runner.egraph, cost_func);
    let (best_cost, best) = extractor.find_best(runner.roots[0]);
    let memory = memory_stats().expect("could not get current memory usage");
    println!("{} & {} & {} & {} & {:.2}", runner.iterations.len(), 
        thousand_seperator(runner.egraph.total_number_of_nodes()), 
        thousand_seperator(runner.egraph.number_of_classes()),
        if matches!(runner.stop_reason.as_ref().unwrap(), egg::StopReason::Saturated) {"\\yes"} else {"\\no"},
        (memory.physical_mem as f64) / (1024.0 * 1024.0) );
    // println!("{:?}", runner.egraph);
    // println!("{}", best);
    let out_str = sdql_print(best, false);
    // println!("init cost:\t{}", SDQLCost { egraph: &runner.egraph }.cost_rec(&start_expr));
    println!("Final Cost: {}", best_cost);
    fs::write(output_file, out_str).expect("Unable to write file");
    // runner.egraph.dot().to_png("target/out.png").unwrap();
    // runner.egraph.dot().to_dot("target/out.dot").unwrap();

    // let cost_test_file = "progs/cost_test.sexp";
    // let cost_test = fs::read_to_string(cost_test_file).expect("Unable to read file").parse().unwrap();
    // let cost_test_cost = cost_func.cost_rec(&cost_test);
    // println!("test cost:\t{}", cost_test_cost);

    // println!("{}", runner.explain_equivalence(&start_expr, &best).get_flat_string());
}
