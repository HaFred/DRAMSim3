#!/bin/bash

# this bash file assumes the resnet block is basic block

layers_type=('Conv1' 'CBa' 'FC6')
cba_suffix_type=(2 3 4 5)
cba_2suffix_type=('a' 'b' 's')
dram_type=('ofmap_write' 'filter_read' 'ifmap_read')
resnet_basic_block=(1 2)
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
						./build_mod/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t tests/ready_out/dram/resnet18_dram_${d}_${l}${cs}${css}.csv -o tests/ready_out/trace_out -f ${d}_${l}${cs}${css}
					else
						for bn in ${resnet_basic_block[@]}
						do
							# echo "resnet18_dram_${d}_${l}${cs}${css}_${bn}.csv"
							./build_mod/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t tests/ready_out/dram/resnet18_dram_${d}_${l}${cs}${css}_${bn}.csv -o tests/ready_out/trace_out -f ${d}_${l}${cs}${css}_${bn}
						done
					fi
				fi
			done
		done
	   else
		# echo "resnet18_dram_${d}_${l}.csv"
		./build_mod/dramsim3main configs/DDR4_8Gb_x8_3200.ini -c 5000000 -t tests/ready_out/dram/resnet18_dram_${d}_${l}.csv -o tests/ready_out/trace_out -f ${d}_${l}
	  fi
	done
done
