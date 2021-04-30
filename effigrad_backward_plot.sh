# this bash could be used to directly dump out pdf graph given the incsv,
# or when the forward dransim is generated, could run the barchart_effi_backward.py here to
# plot the effigrad_backward phase.

echo "Setting the trace output name: $1" # output of dramsim, traces_apr28_comb_os_vani_backward
echo "Setting the stats output dir: $2"  # output of dramsim, stats_apr28_comb_os_vani_backward
echo "Setting the dataflow for input csv and input folder name: $3" # has to be ws or os

# include python matplotlib cmd here
cd ./latest_output
pwd=$(pwd)
cd /home/zhongad/PycharmProjects/matplotProject/src/

# [forward/vani_backward] this 2 lines needs to change
# python barchart_vani_backward.py --df=$3 --vt=average_power --incsv=${pwd}/$2/
# python barchart_vani_backward.py --df=$3 --vt=total_energy --incsv=${pwd}/$2/
python barchart_effgrad_backward.py --df=$3 --vt=average_power --incsv=${pwd}/$2/
python barchart_effgrad_backward.py --df=$3 --vt=total_energy --incsv=${pwd}/$2/

# get back to the original path
cd /home/zhongad/playground/DRAMSim3-Fred/latest_output