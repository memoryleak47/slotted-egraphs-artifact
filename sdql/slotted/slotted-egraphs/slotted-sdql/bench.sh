stage1=("batax_v0" "mmm_sum_v0" "mmm_v0" "mttkrp_v0" "ttm_v0")
stage2=("batax_v7_csr_dense_unfused" "mmm_sum_v7_csc_csr_unfused" "mmm_v7_csr_csr_unfused" "mttkrp_v7_csf_csr_csc_unfused" "ttm_v1_csf_csr_unfused")

for file in "${stage1[@]}"
do
  eval "sh run.sh $file" >> gen_log1.txt
done

for file in "${stage2[@]}"
do
  eval "sh run.sh $file" >> gen_log2.txt
done