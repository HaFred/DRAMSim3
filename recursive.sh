#!/bin/bash

# recursive.sh
# perform DRAMSim simulation based on SCALE-Sim traces and dump the result into $1, and then grep the output stats to record the average_power and total_energy into csv files in $2.
# it assumes the resnet block is basic block.

# recursively running, ./latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 10000 -t ./latest_output/apr27_test/test_combine.csv -o ./latest_output/apr27_test/ -f test_combine

echo "Setting the trace output name: $1" # traces_vani_backward
echo "Setting the stats output dir: $2"  # stats_vani_backward_apr19
echo "Setting the dataflow for input csv and input folder name: $3" # has to be ws or os
layers_type=('Conv1' 'Conv' 'FC6')
cba_suffix_type=(2 3 4 5)
cba_2suffix_type=('a' 'b' 's')
dram_type=('ofmap_write' 'filter_read' 'ifmap_read')

# [forward/vani_backward] these lines needs to change
dram_traces_dir=/home/zhongad/playground/SCALE-Sim-Fred/outputs/apr28_comb_${3}_effgrad_16x16_resnet18_vani_backward/DRAM
dram_traces_name_prefix=resnet18_vani_backward_dram
# dram_traces_dir=/home/zhongad/playground/SCALE-Sim-Fred/outputs/apr28_comb_${3}_effgrad_16x16_resnet18_forward/DRAM
# dram_traces_name_prefix=resnet18_dram

resnet_basic_block=(1 2)
mkdir -p latest_output/$1
# block_dist=(2 2 2 2)
for d in ${dram_type[@]}
do
	for l in ${layers_type[@]}
	do
	  # echo $l
	  if [[ $l  == 'Conv' ]] ; then	  
		# echo "got it"
		for cs in ${cba_suffix_type[@]}
		do
			# l+=$cs
			for css in ${cba_2suffix_type[@]}
			do
				if [[ !(($cs == 2) && ($css == 's')) ]] ; then
					if [[ $css == 's' ]] ; then
						# echo "resnet18_dram_${d}_${l}${cs}${css}.csv"
						# below is what defined in dramsim3, -t for input dram traces, -o for output_dir, -f output_file_name
						# for -c, just gives a large number to make sure each trace could run out of its cycles
						latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t ${dram_traces_dir}/${dram_traces_name_prefix}_${d}_${l}${cs}${css}.csv -o latest_output/$1 -f ${d}_${l}${cs}${css}
					else
						for bn in ${resnet_basic_block[@]}
						do
							# echo "resnet18_dram_${d}_${l}${cs}${css}_${bn}.csv"
							latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t ${dram_traces_dir}/${dram_traces_name_prefix}_${d}_${l}${cs}${css}_${bn}.csv -o latest_output/$1 -f ${d}_${l}${cs}${css}_${bn}
						done
					fi
				fi
			done
		done
	   else
		# echo "resnet18_dram_${d}_${l}.csv"
		latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t ${dram_traces_dir}/${dram_traces_name_prefix}_${d}_${l}.csv -o latest_output/$1 -f ${d}_${l}
	  fi
	done
done
cd latest_output/$1
grep -ri 'average_power' > ../average_power.txt
grep -ri 'total_energy' > ../total_energy.txt
cd ..
pwd
# python  
value_type=('average_power' 'total_energy')
for vt in ${value_type[@]}
do
	for d in ${dram_type[@]}
	do
		python ../scripts/csv_gen.py --value_name=$vt --workload_type_name=$d --input-txt=${vt}.txt --output-csv=${vt}_${d}.csv
	done
done
mkdir $2
mv *.csv $2
mv *.txt $2 

# include python matplotlib cmd here
pwd=$(pwd) # at ~/latest_output
cd /home/zhongad/PycharmProjects/matplotProject/src/

# [forward/vani_backward] this 2 lines needs to change
python barchart_vani_backward.py --df=$3 --vt=average_power --incsv=${pwd}/$2/
python barchart_vani_backward.py --df=$3 --vt=total_energy --incsv=${pwd}/$2/
# get back to the original path
cd /home/zhongad/playground/DRAMSim3-Fred/latest_output