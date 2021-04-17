#!/bin/bash

# this bash file assumes the resnet block is basic block

layers_type=('Conv1' 'CBa' 'FC6')
cba_suffix_type=(2 3 4 5)
cba_2suffix_type=('a' 'b' 's')
dram_type=('ofmap_write' 'filter_read' 'ifmap_read')
resnet_basic_block=(1 2)
mkdir -p latest_output/trace_out
# block_dist=(2 2 2 2)
for d in ${dram_type[@]}
do
	for l in ${layers_type[@]}
	do
	  # echo $l
	  if [[ $l  == 'CBa' ]] ; then	  
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
						latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t latest_output/dram/resnet18_dram_${d}_${l}${cs}${css}.csv -o latest_output/trace_out -f ${d}_${l}${cs}${css}
					else
						for bn in ${resnet_basic_block[@]}
						do
							# echo "resnet18_dram_${d}_${l}${cs}${css}_${bn}.csv"
							latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t latest_output/dram/resnet18_dram_${d}_${l}${cs}${css}_${bn}.csv -o latest_output/trace_out -f ${d}_${l}${cs}${css}_${bn}
						done
					fi
				fi
			done
		done
	   else
		# echo "resnet18_dram_${d}_${l}.csv"
		latest_build/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t latest_output/dram/resnet18_dram_${d}_${l}.csv -o latest_output/trace_out -f ${d}_${l}
	  fi
	done
done
cd latest_output/trace_out
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
