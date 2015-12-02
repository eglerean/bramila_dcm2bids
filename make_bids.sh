# from dicom to bids, includes defacing with mri_deface

tag="movie_fMRI"
NS=3;
subprefix=""
Nruns=3;
declare -a subjIDs=("3595" "3612" "3880");

declare -a tasks=( "rest" "movie" "rest")
anat_id='00005';
declare -a funct_id=("00002" "00003" "00004")
basepath='./braindata/eglerean/PAS/';

i=1;
for s in ${subjIDs[@]}; do
	## sub-<participant_label>[_acq-<label>][_rec-<label>][_run-<index>]_T1w.nii.gz
	echo mkdir -p $basepath/$tag/sub-$subprefix$i/anat
	mkdir -p $basepath/$tag/sub-$subprefix$i/anat

	echo "###" Creating file $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w_nodeface.nii"
	echo "###" Creating file $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w.json"
	echo dcm2niix -b y -o $basepath/$tag/sub-$subprefix$i/anat -f sub-$subprefix$i"_T1w_nodeface" $basepath/$s/$s/$anat_id 
	dcm2niix -b y -o $basepath/$tag/sub-$subprefix$i/anat -f sub-$subprefix$i"_T1w_nodeface" $basepath/$s/$s/$anat_id 
	
	
	echo mv $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w_nodeface.json $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w.json
	echo "### Defacing: " $basepath/bin/mri_deface $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w_nodeface.nii" $basepath/bin/talairach_mixed_with_skull.gca $basepath/bin/face.gca $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w.nii"
	$basepath/bin/mri_deface $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w_nodeface.nii" $basepath/bin/talairach_mixed_with_skull.gca $basepath/bin/face.gca $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w.nii"
	
	echo rm $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w_nodeface.nii"
	rm $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w_nodeface.nii"
	echo gzip $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w.nii"
	gzip $basepath/$tag/sub-$subprefix$i/anat/sub-$subprefix$i"_T1w.nii"
	
	

	## sub-<participant_label>/func/sub-<participant_label>_task-<task_label>[_acq-<label>][_run-<index>]_bold.json
	echo mkdir -p $basepath/$tag/sub-$subprefix$i/func
	mkdir -p $basepath/$tag/sub-$subprefix$i/func
	
	let lim=$Nruns-1;
	
	for r in $(seq 0 $lim); do
		let rr=$r+1;
		echo "### Creating " $basepath/$tag/sub-$subprefix$i/func/sub-$subprefix$i"_task-"${tasks[$r]}"_acq-EPI_run-"$rr"_bold"
		echo dcm2niix -b y -o $basepath/$tag/sub-$subprefix$i/func -f sub-$subprefix$i"_task-"${tasks[$r]}"_acq-EPI_run-"$rr"_bold" $basepath/$s/$s/${funct_id[$r]}
		dcm2niix -b y -o $basepath/$tag/sub-$subprefix$i/func -f sub-$subprefix$i"_task-"${tasks[$r]}"_acq-EPI_run-"$rr"_bold" $basepath/$s/$s/${funct_id[$r]}
		if [ $r -eq 1 ]; then
			cp $basepath/$s/$s.log $basepath/$tag/sub-$subprefix$i/func/sub-$subprefix$i"_task-"${tasks[$r]}"_acq-EPI_run-"$rr"_events.tsv"
		fi
	done

	let i=$i+1;
done 

# extra folders for data perservation
mkdir ./braindata/eglerean/PAS/movie_fMRI/permissions
mkdir ./braindata/eglerean/PAS/movie_fMRI/stimuli
mkdir ./braindata/eglerean/PAS/movie_fMRI/experiments

