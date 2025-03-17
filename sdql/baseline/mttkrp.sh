echo "coarse:" >> mttkrp.txt
eval "sh run.sh mttkrp_2nd ind coarse" >> mttkrp.txt
echo "fine:" >> mttkrp.txt
eval "sh run.sh mttkrp_2nd ind fine" >> mttkrp.txt