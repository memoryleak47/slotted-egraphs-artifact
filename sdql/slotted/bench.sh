stage1=("mmm_sum_1st" "mttkrp_1st" "mmm_1st" "ttm_1st" "batax_1st")
stage2=("mmm_sum_2nd" "mttkrp_2nd" "mmm_2nd" "ttm_2nd" "batax_2nd")

echo "Kernel & System & Iters. & Nodes & Classes & Saturated & Memory (MB)" >> bench.txt

for file in "${stage1[@]}"
do
  eval "sh run.sh $file e2e fine" >> bench.txt
done

for file in "${stage2[@]}"
do
  eval "sh run.sh $file e2e fine" >> bench.txt
done