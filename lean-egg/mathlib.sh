#!/bin/bash

script_dir="$(realpath -s "$(dirname "$0")")"

mathlib_dir="$script_dir/Lean/Egg/Tests/mathlib4/mathlib4"
cd "$mathlib_dir"

log_dir="$script_dir/mathlib-logs"
mkdir -p "$log_dir"

if [ -z "$1" ] || [ "$1" -le "1" ]; then
    echo "(1) Building Mathlib"
    echo -n "" > "$log_dir/step-1.txt"
    sleep 3
    # lake clean
    lake build | tee "$log_dir/step-1.txt" | grep '✔'
fi

if [ -z "$1" ] || [ "$1" -le "2" ]; then
    echo "(2) Collecting Results"
    echo -n "" > "$log_dir/step-2.txt"
    grep '^info.*egg' "$log_dir/step-1.txt" > "$log_dir/step-2.txt"
fi

if [ -z "$1" ] || [ "$1" -le "3" ]; then
    echo "(3) Matching Slotted and Egg Results"
    echo -n "" > "$log_dir/step-3.txt"
    while true; do
        IFS= read -r line_1 || break
        IFS= read -r line_2 || line_2=""
        
        # Checks that we always have pairs of lines referring to the same location.
        # The first one is the call to egg with the egg backend, the second one the
        # call with the slotted backend.
        line_1_prefix="$(echo "$line_1" | grep -o '^info: \S*')"
        line_2_prefix="$(echo "$line_2" | grep -o '^info: \S*')"
        if [ "$line_1_prefix" != "$line_2_prefix" ]; then
            echo "ERROR: pairs of slotted and egg calls don't match up"
            echo "$line_1_prefix"
            echo "$line_2_prefix"
            exit 1
        fi

        # Writes the suffixes of each line (which contains the outcome of a call) to 
        # "step-3.txt".
        line_1_outcome="$(echo "$line_1" | grep -E -o 'egg (succeeded|failed).*$')"
        line_2_outcome="$(echo "$line_2" | grep -E -o 'egg (succeeded|failed).*$')"
        echo "$line_1_outcome" >> "$log_dir/step-3.txt"
        echo "$line_2_outcome" >> "$log_dir/step-3.txt"
    done < "$log_dir/step-2.txt"
fi

if [ -z "$1" ] || [ "$1" -le "4" ]; then
    echo "(4) Pruning Non-Applicable Calls"
    echo -n "" > "$log_dir/step-4.txt"
    while true; do
        IFS= read -r line_1 || break
        IFS= read -r line_2 || line_2=""
        
        non_applicable_0="egg failed: egg received invalid explanation: step contains non-defeq type-level rewrite in proof"
        non_applicable_1="egg failed: egg requires rewrites to be equalities, equivalences or (non-propositional) definitions"
        non_applicable_2="egg failed: typeclass instance problem is stuck, it is often due to metavariables"
        non_applicable_3="egg failed: egg failed to build proof:"
        non_applicable_4="egg failed: egg: final proof contains expression mvar"
        non_applicable_5="egg failed: 'Egg.Explanation.ToExprM.mapBVar' received loose bvar"

        # Prunes non-applicable calls while also checking that they match up between the two
        # backends.
        if [ "$line_1" = "$non_applicable_1" ] || [ "$line_2" = "$non_applicable_1" ] || [ "$line_1" = "$non_applicable_2" ] || [ "$line_2" = "$non_applicable_2" ]; then
            if [ "$line_1" != "$line_2" ]; then
                echo "ERROR: non-applicable calls don't match up"
                echo "$line_1"
                echo "$line_2"
                exit 1
            fi
        elif [[ "$line_1" == "$non_applicable_0"* ]] || [[ "$line_2" == "$non_applicable_0"* ]] || [[ "$line_1" == "$non_applicable_3"* ]] || [[ "$line_2" == "$non_applicable_3"* ]] || [[ "$line_1" == "$non_applicable_4"* ]] || [[ "$line_2" == "$non_applicable_4"* ]] || [[ "$line_1" == "$non_applicable_5"* ]] || [[ "$line_2" == "$non_applicable_5"* ]]; then
            :
        else
            echo "$line_1" >> "$log_dir/step-4.txt"
            echo "$line_2" >> "$log_dir/step-4.txt"
        fi
    done < "$log_dir/step-3.txt"
fi

if [ -z "$1" ] || [ "$1" -le "5" ]; then
    echo "(5) Gathering Statistics"
    echo -n "" > "$log_dir/step-5-egg.txt"
    echo -n "" > "$log_dir/step-5-slotted.txt"
    while true; do
        IFS= read -r line_1 || break
        IFS= read -r line_2 || line_2=""
    

        line_1_outcome="$(echo "$line_1" | grep -E -o 'egg (succeeded|failed)')"
        line_2_outcome="$(echo "$line_2" | grep -E -o 'egg (succeeded|failed)')"

        # if [ "$line_1_outcome" != "$line_2_outcome" ]; then
        #     echo "Different Outcomes!"
        #     echo "$line_1"
        #     echo "$line_2"
        # fi

        if [ "$line_1_outcome" = "egg succeeded" ]; then
            echo "$(echo "$line_1" | cut -d',' -f8) $(echo "$line_1" | cut -d',' -f7)" >> "$log_dir/step-5-egg.txt"
        else
            echo "failed" >> "$log_dir/step-5-egg.txt"
        fi

        if [ "$line_2_outcome" = "egg succeeded" ]; then
            echo "$(echo "$line_2" | cut -d',' -f8) $(echo "$line_2" | cut -d',' -f7)" >> "$log_dir/step-5-slotted.txt"
        else
            echo "failed" >> "$log_dir/step-5-slotted.txt"
        fi
    done < "$log_dir/step-4.txt"
fi

echo -e "(6) Computing Final Results\n"
num_test_cases="$(cat "$log_dir/step-5-egg.txt" | wc -l | awk '{$1=$1; print}')"
egg_num_successes="$(cat "$log_dir/step-5-egg.txt" | grep -E '(true|false)' | wc -l | awk '{$1=$1; print}')"
slotted_num_successes="$(cat "$log_dir/step-5-slotted.txt" | grep -E '(true|false)' | wc -l | awk '{$1=$1; print}')"

egg_expl_length_sum="$(cat "$log_dir/step-5-egg.txt" | grep -o '\d*' | awk '{ sum += $1 } END { print sum }')"
slotted_expl_length_sum="$(cat "$log_dir/step-5-slotted.txt" | grep -o '\d*' | awk '{ sum += $1 } END { print sum }')"
egg_expl_length_avg="$(echo "$egg_expl_length_sum / $egg_num_successes" | bc -l | awk '{$1=$1; print}')"
slotted_expl_length_avg="$(echo "$slotted_expl_length_sum / $slotted_num_successes" | bc -l | awk '{$1=$1; print}')"

egg_with_binders_successes="$(cat "$log_dir/step-5-egg.txt" | grep 'true')"
slotted_with_binders_successes="$(cat "$log_dir/step-5-slotted.txt" | grep 'true')"
egg_with_binders_num_successes="$(echo "$egg_with_binders_successes" | wc -l | awk '{$1=$1; print}')"
slotted_with_binders_num_successes="$(echo "$slotted_with_binders_successes" | wc -l | awk '{$1=$1; print}')"
with_binders_egg_expl_length_sum="$(echo "$egg_with_binders_successes" | grep -o '\d*' | awk '{ sum += $1 } END { print sum }')"
with_binders_slotted_expl_length_sum="$(echo "$slotted_with_binders_successes" | grep -o '\d*' | awk '{ sum += $1 } END { print sum }')"
with_binders_egg_expl_length_avg="$(echo "$with_binders_egg_expl_length_sum / $egg_with_binders_num_successes" | bc -l | awk '{$1=$1; print}')"
with_binders_slotted_expl_length_avg="$(echo "$with_binders_slotted_expl_length_sum / $slotted_with_binders_num_successes" | bc -l | awk '{$1=$1; print}')"

echo -e "Total Number of Test Cases: $num_test_cases\n"
echo "Backend | Successful Proven Theorems | Average Explanation Length | ...With Binders"
echo "-----------------------------------------------------------------------------------"
echo "slotted | $slotted_num_successes                        | ${slotted_expl_length_avg:0:4}                       | ${with_binders_slotted_expl_length_avg:0:4}"
echo "egg     | $egg_num_successes                        | ${egg_expl_length_avg:0:4}                       | ${with_binders_egg_expl_length_avg:0:4}"