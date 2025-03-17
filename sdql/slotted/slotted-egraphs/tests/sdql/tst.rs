use crate::*;
use std::fs;
// use memory_stats::memory_stats;
use std::time::Instant;
// use tracing::*;
pub use slotted_egraphs::*;

// #[tracing::instrument(level = "trace", skip_all)]
// fn iteration_stats<W, L, N>(csv_out: &mut W, it_number: usize, eg: &EGraph<L, N>, found: bool, start_time: Instant) -> bool
//     where W: std::io::Write, L: Language, N: Analysis<L>
// {
//     let memory = memory_stats().expect("could not get current memory usage");
//     let out_of_memory = memory.virtual_mem > 4_000_000_000;
//     writeln!(csv_out, "{}, {}, {}, {}, {}, {}, {}, {}",
//         it_number,
//         memory.physical_mem,
//         memory.virtual_mem,
//         eg.total_number_of_nodes(),
//         eg.total_number_of_nodes(), // TODO: remove
//         // eg.ids().into_iter().map(|c| eg.enodes(c).len()).sum::<usize>(),
//         eg.ids().len(),
//         start_time.elapsed().as_secs_f64(),
//         found).unwrap();
//     out_of_memory
// }

pub fn id<L: Language, A: Analysis<L>>(s: &str, eg: &mut EGraph<L, A>) -> AppliedId {
    // eg.check();
    let re = RecExpr::parse(s).unwrap();
    let out = eg.add_syn_expr(re.clone());
    // eg.check();
    out
}

pub fn is_same<L: Language, A: Analysis<L>>(s1: &str, s2: &str, eg: &mut EGraph<L, A>) -> bool {
    let s1i = id(s1, eg);
    let s2i = id(s2, eg);
    return eg.eq(&s1i, &s2i);
}

fn is_alpha_equiv(s1: &str, s2: &str) -> bool {
    let mut eg: EGraph<Sdql, SdqlKind> = EGraph::new(); // a fresh e-graph knowing zero equations.
    let t1 = RecExpr::parse(s1).unwrap();
    let t2 = RecExpr::parse(s2).unwrap();
    let i1 = eg.add_syn_expr(t1);
    let i2 = eg.add_syn_expr(t2);
    return eg.eq(&i1, &i2);
}

fn get_cost(re: RecExpr<Sdql>) -> usize {
	let mut eg: EGraph<Sdql, SdqlKind> = EGraph::new();
	let id = eg.add_syn_expr(re);
	let cost_func = SdqlCost { egraph: &eg };
    let extractor = Extractor::<_, SdqlCost>::new(&eg, cost_func);
    return extractor.get_best_cost(&id.clone(), &eg);
}
// MTTKRP: needs 12 
// TTM: needs 14
// MMMSUM: needs 9
static DEFAULT_STEPS:usize = 6;

pub fn check_generic(input: &str, expected: &str, debug: bool, steps: usize) {
	let re: RecExpr<Sdql> = RecExpr::parse(input).unwrap();
    let rewrites = sdql_rules();
    // let rewrites = sdql_rules_old();

    let mut eg = EGraph::<Sdql, SdqlKind>::new();

    let id1 = eg.add_syn_expr(re.clone());


	// let csv_out = format!("profile_{input}.csv");
	let csv_out = if debug { "profile.csv" } else { "out.csv" };
	let mut csv_f = std::fs::File::create(csv_out).unwrap();
	let start_time = Instant::now();
    for iteration in 0..steps {
    	apply_rewrites(&mut eg, &rewrites);
    	// if debug {
    	// 	iteration_stats(&mut csv_f, iteration, &eg, true, start_time);
    	// }
    }

    // apply_rewrites(&mut eg, &rewrites);
    let cost_func = SdqlCost { egraph: &eg };
    let extractor = Extractor::<_, SdqlCost>::new(&eg, cost_func);
    let term = extractor.extract(&id1.clone(), &eg);
    let actual = term.to_string();
    if debug {
    	eprintln!("Initial: {}", re.to_string());
    	eprintln!("Expected:{}", expected);
    	eprintln!("Actual:  {}", actual);
    	eprintln!("Init Cost:  {}", get_cost(re));
    	eprintln!("Expc. Cost: {}", get_cost(RecExpr::parse(expected).unwrap()));
    	eprintln!("Final Cost: {}", get_cost(term));
    	eprintln!("Final Cost2:{}", extractor.get_best_cost(&id1.clone(), &eg));

    	
    }
    // assert!(is_same(&actual, s2, &mut eg));
    assert!(is_alpha_equiv(&actual, expected));
}

pub fn check(input: &str, s2: &str) {
	check_generic(input, s2, false, DEFAULT_STEPS)
}

pub fn check_file_generic(input_path: &str, expected_path: &str, debug: bool, steps: usize) {
	let folder = "tests/sdql/progs";
	let input = fs::read_to_string(format!("{folder}/{input_path}.sexp")).expect("Unable to read file");
	let expected = fs::read_to_string(format!("{folder}/{expected_path}.sexp")).expect("Unable to read file");
	check_generic(&input, &expected, debug, steps);
}

pub fn check_file(input_path: &str, expected_path: &str) {
	check_file_generic(input_path, expected_path, false, DEFAULT_STEPS);
}

pub fn check_file_steps(input_path: &str, expected_path: &str, steps: usize) {
	check_file_generic(input_path, expected_path, false, steps);
}

pub fn check_file_debug(input_path: &str, expected_path: &str) {
	check_file_generic(input_path, expected_path, true, DEFAULT_STEPS);
}

pub fn check_debug(input: &str, s2: &str) {
	check_generic(input, s2, true, DEFAULT_STEPS)
}

#[test]
fn t1() {
    check("(lambda $R (lambda $a (sum $i $j (var $R) (sing (var $a) (var $j)))))", 
    	  "(lambda $R (lambda $a (sing (var $a) (sum $i $j (var $R) (var $j)))))")
}

#[test]
fn dce1() {
    check("(lambda $a (let $b (var $a) (var $a)))", "(lambda $a (var $a))")
}

#[test]
fn blow1() {
    check("(lambda $a (let $x (* (var $a) (var $a)) (var $x)))", "(lambda $var_1 (* (var $var_1) (var $var_1)))")
}

#[test]
fn blow2() {
    check("(lambda $a (let $x (var $a) (* (var $a) (var $x))))", "(lambda $var_1 (* (var $var_1) (var $var_1)))")
}

#[test]
fn blow3() {
	check("(lambda $a
	(let $x (binop op1 (var $a) (var $a)) (binop op2 (var $x) (var $a)))
)", "(lambda $var_01 (let $var_02 (binop op1 (var $var_01) (var $var_01)) (binop op2 (var $var_02) (var $var_01))))")
}

#[test]
fn blow4() {
    check("(lambda $a (lambda $b (let $x (let $y (* (var $a) (var $b)) (+ (var $y) (* (var $y) (var $b)))) (+ (var $x) (* (var $x) (var $b)))) ) )", 
    	"(lambda $var_1 (lambda $var_2 (let $var_3 (+ (* (var $var_1) (var $var_2)) (* (var $var_1) (* (var $var_2) (var $var_2)))) (+ (var $var_3) (* (var $var_3) (var $var_2))))))")
}

#[test]
fn paper_example3() {
	check("(* a (sing k (+ b c)))", "(sing k (* a (+ b c)))")
}

#[test]
fn fuse_csr1() {
	check("(lambda $Row (lambda $N 
	(let $R (sum $i $j (range 1 (var $N)) (sing (unique (var $j)) (get (var $Row) (var $j))))
		(sum $i2 $j2 (var $R) (var $j2))
	)
))", "(lambda $var_1 (lambda $var_2 (sum $var_3 $var_4 (range 1 (var $var_2)) (get (var $var_1) (var $var_4)))))")
}

#[test]
fn sum_vert_fuse1() {
	check("(lambda $R (lambda $a
	(sum $i $j (sum $i2 $j2 (var $R) (sing (var $i2) (var $j2))) (sing (* (var $a) (var $i)) (var $j)))
))", "(lambda $var_01 (lambda $var_02 (sum $var_03 $var_04 (var $var_01) (sing (* (var $var_02) (var $var_03)) (var $var_04)))))")
}

#[test]
fn sum_vert_fuse2() {
	check("(lambda $R (lambda $a
	(get (sum $i2 $j2 (var $R) (sing (var $i2) (var $j2))) (* (var $a) 22))
))", "(lambda $var_01 (lambda $var_02 (get (var $var_01) (* (var $var_02) 22))))")
}

#[test]
fn sum_vert_fuse3() {
	check("(lambda $R (lambda $a
	(sum $i $j (sum $i2 $j2 (var $R) (sing (unique (* (var $i2) (var $a))) (var $j2))) (sing (* (var $a) (var $i)) (var $j)))
))", "(lambda $var_01 (lambda $var_02 (sum $var_03 $var_04 (var $var_01) (sing (* (var $var_02) (* (var $var_03) (var $var_02))) (var $var_04)))))")
}

#[test]
fn sum_vert_fuse4() {
	check("(lambda $R (lambda $a
	(sum $i $j (sum $i2 $j2 (var $R) (sing (var $i2) (var $j2))) (sing (var $j) (var $a)))
))", "(lambda $var_01 (lambda $var_02 (sum $var_03 $var_04 (var $var_01) (sing (var $var_04) (var $var_02)))))")
}

#[test]
fn sum_fact1() {
	check("(lambda $R (lambda $a
	(sum $i $j (var $R) (sing (var $a) (var $j)))
))", "(lambda $var_01 (lambda $var_02 (sing (var $var_02) (sum $var_03 $var_04 (var $var_01) (var $var_04)))))")
}

#[test]
fn sum_fact2() {
	check("(lambda $R (lambda $a
	(sum $i $j (var $R) (* 1.5 (var $j)))
))", "(lambda $var_01 (lambda $var_02 (* 1.5 (sum $var_03 $var_04 (var $var_01) (var $var_04)))))")
}

#[test]
fn sum_fact3() {
	check("(lambda $R (lambda $a
	(sum $i $j (var $R) (* 15 (sum $i2 $j2 (var $a) (var $j2))))
))", "(lambda $var_01 (lambda $var_02 
    (* (sum $var_03 $var_04 (var $var_01) 15) (sum $var_03 $var_04 (var $var_02) (var $var_04)))
))")
}

#[test]
fn sum_merge1() {
	check("(lambda $R (lambda $S
	(sum $k1 $v1 (var $R) (sum $k2 $v2 (var $S) (ifthen (eq (var $v1) (var $v2)) (* (var $k1) (var $v1)))))
))", "(lambda $var_01 (lambda $var_02 
    (merge $var_03 $var_05 $var_04 (var $var_01) (var $var_02) (* (var $var_03) (var $var_04)))
))")
}

#[test]
fn sum_merge2() {
	check("(lambda $R (lambda $S
	(sum $k1 $v1 (var $R) (sum $k2 $v2 (var $S) (ifthen (eq (var $v1) (var $v2)) (* (var $k1) (var $v2)))))
))", "(lambda $var_01 (lambda $var_02 
    (merge $var_03 $var_05 $var_04 (var $var_01) (var $var_02) (* (var $var_03) (var $var_04)))
))")
}

#[test]
fn batax_v0() {
	check_file("batax_v0", "batax_v0_esat")
}

#[test]
fn mmm_sum_v0() {
	check_file("mmm_sum_v0", "mmm_sum_v0_esat")
}

#[test]
fn mmm_v0() {
	check_file("mmm_v0", "mmm_v0_esat")
}

#[test]
fn mttkrp_v0() {
	check_file("mttkrp_v0", "mttkrp_v0_esat")
}

#[test]
fn ttm_v0() {
	check_file("ttm_v0", "ttm_v0_esat")
}

#[test]
fn mmm_sum_v7_csc_csr_unfused() {
	check_file_steps("mmm_sum_v7_csc_csr_unfused", "mmm_sum_v7_csc_csr_unfused_esat", 9)
}


#[test]
fn mmm_v7_csr_csr_unfused() {
	check_file_steps("mmm_v7_csr_csr_unfused", "mmm_v7_csr_csr_unfused_esat", 6)
}

#[test]
fn batax_v7_csr_dense_unfused() {
	check_file_steps("batax_v7_csr_dense_unfused", "batax_v7_csr_dense_unfused_esat", 8)
}

#[test]
fn mttkrp_v7_csf_csr_csc_unfused() {
	check_file_steps("mttkrp_v7_csf_csr_csc_unfused", "mttkrp_v7_csf_csr_csc_unfused_esat", 12)
}

#[test]
fn ttm_v1_csf_csr_unfused() {
	check_file_steps("ttm_v1_csf_csr_unfused", "ttm_v1_csf_csr_unfused_esat", 14)
}

// #[test]
// fn batax_full() {
// 	check_file_steps("batax_full", "batax_v7_csr_dense_unfused_esat", 8)
// }

// #[test]
// fn mmm_sum_full() {
// 	check_file_steps("mmm_sum_full", "mmm_sum_v7_csc_csr_unfused_esat", 19)
// }