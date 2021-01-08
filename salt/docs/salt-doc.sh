#!/bin/bash
while getopts s:d:h: flag

do
    case "${flag}" in 

	s) main_sls_file=${OPTARG};;
 	d) output_folder=${OPTARG};;
        h) echo "

                 Usage: ./salt-doc.sh -s /srv/salt/BuildTemplate/Template.sls  -d /home/ebennett-dev/
                 -s flag should point to the main orchestration state, should include the full path with the initial slash '/' and the .sls ending
                 -d flag should point to the location where you want the resulting files to be placed.  Specify the full path

                 "
           exit 0
	   ;;
    esac
done

##format the variable arguments  for use in the script

IFS='/' read -ra my_array <<< "$main_sls_file"
main_sls_name=${my_array[${#my_array[@]} - 1]}
unset 'my_array[${#my_array[@]}-1]'

for word in ${my_array[@]}; do
   main_sls_path=$main_sls_path/$word

done

main_sls_path=$main_sls_path/


pat="^[a-zA-Z0-9].*"
if [[ $output_folder =~ $pat ]]; then
output_folder="/"$output_folder
fi

pat="[a-zA-Z0-9]$"
if [[ $output_folder =~ $pat ]]; then
output_folder=$output_folder"/"
fi

cdate=$(date +"%m.%d.%y")
main_file=$(echo $main_sls_file | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}') 
process_doc=$main_file"-"$cdate"-process.doc"
manifest_doc=$main_file"-"$cdate"-manifest.doc"
variables_doc=$main_file"-"$cdate"-variables.doc"
cmd_doc=$main_file"-"$cdate"-cmdrun.doc"
touch $output_folder$manifest_doc
touch $output_folder$variables_doc
touch $output_folder$cmd_doc

#actual script to create the doc.
cat $main_sls_file  | grep -E -A1 "^[[:alnum:]]+[[:alnum:][:space:]]+"\|"mods.*"\|"\- sls:" | grep -v "salt.*"  | grep -v "\-\-" | grep -v "pillar" | grep -v "sls"| grep -v " [[:alnum:]]\+\.[[:alnum:]]\+:" | sed 's/^      \-/    \- mods:/' > $output_folder$process_doc
echo "$main_sls_file" | sed 's/\/srv\/salt\//    - mods: /' | awk -F'.' '{print $1}' >> $output_folder$process_doc
#cat $output_folder$process_doc
COUNT=$(cat $output_folder$process_doc | grep -E "\- mods:" | wc -l)	
#echo "The process file doc location is " $output_folder$process_doc

while [ $COUNT -gt 0 ]
do	
   FILE=$(cat $output_folder$process_doc | grep -E "mods.*" | head -1 | awk 'BEGIN { FS = "[/ ]" } ; { print $NF }')
   FILEPATH=$(cat $output_folder$process_doc | grep -E "mods.*" | head -1 | awk 'BEGIN { FS = ": " } ; { print $NF }')
   FILENAME="/srv/salt/${FILEPATH}".sls
   FILELOC="/tmp/${FILE}".doc
   if [[  "$main_sls_file" != "$FILENAME" ]];then
      echo $FILENAME >> $output_folder$manifest_doc
      cat $FILENAME | grep -E -A3 "^[[:alnum:]]+[[:alnum:][:space:]]+"\|"mods.*"\|"\- sls:" | grep -v "salt.*"  | grep -v "\-\-" | grep -v "pillar" | grep -v "sls" | grep -v " [[:alnum:]]\+\.[[:alnum:]]\+:" | sed 's/^      \-/    \- mods:/' | grep -E "^[[:alnum:]]"\|"mods" > $FILELOC
      sed -i 's/^/    /' $FILELOC
      awk -v value="$(cat $FILELOC)" '/mods/ && ++count==1{sub(/   - mods:.*/, value)} 1' $output_folder$process_doc > /tmp/temp_file && mv /tmp/temp_file $output_folder$process_doc
      grep -i "% set.*salt\[" $FILENAME | sed 's/.*salt\[//' | sed 's/\..*//' | awk -F"'" '{print $2}' | sort | uniq >> $output_folder$manifest_doc
      cat $FILENAME | grep -A1 "salt\..*$" | grep -v "state\.orch" | grep "name" | awk '{print $3}' | awk -F'.' '{print $1}' | sort | uniq >> $output_folder$manifest_doc
      cat $FILENAME | grep -A1 "module"  | grep -v module | awk '{print $3}' | awk -F"." '{print $1}' | sort | uniq >> $output_folder$manifest_doc
      cat $FILENAME  | grep import | awk -F '"' '{print $2}' | awk -F '/' '{print $NF}' | awk -F'.' '{print $(NF-1)}' | sed 's/$/.sls/' | sed "s|^|$main_sls_path|" >> $output_folder$manifest_doc
      echo $FILENAME >> $output_folder$variables_doc
      cat $FILENAME |  grep -E "^[[:space:]]+[[:alnum:]]+:[[:space:]]+[^{]"\|"^[[:space:]]+-[[:space:][:alnum:]:]+" | grep -v "\- name" | grep -v "\- pillar" | grep -v "\- mods" | grep -v "{" | grep -v  "sls" | grep -v "retry" | grep -v "attempts:" | grep -v "until:" | grep -v "interval:" | grep -v "splay" | grep -v "s_time" >> $output_folder$variables_doc
      echo $FILENAME >> $output_folder$cmd_doc
      cat $FILENAME |  grep -E -A1 "cmd.run" | grep -v "cmd.run" | grep -v "^\-\-" >> $output_folder$cmd_doc
   else
      grep -i "% set.*salt\[" $main_sls_file | sed 's/.*salt\[//' | sed 's/\..*//' | awk -F"'" '{print $2}' | sort | uniq >> $output_folder$manifest_doc
      cat $main_sls_file | grep -A1 "salt\..*$" | grep -v "state\.orch" | grep "name" | awk '{print $3}' | awk -F'.' '{print $1}' | sort | uniq >> $output_folder$manifest_doc
      cat $main_sls_file | grep -A1 "module"  | grep -v module | awk '{print $3}' | awk -F"." '{print $1}' | sort | uniq >> $output_folder$manifest_doc
      cat $main_sls_file | grep import | awk -F '"' '{print $2}' | awk -F '/' '{print $NF}' | awk -F'.' '{print $(NF-1)}'| sed 's/$/.sls/' | sed "s|^|$main_sls_path|" >> $output_folder$manifest_doc
      echo $main_sls_file >> $output_folder$variables_doc
      echo $main_sls_file >> $output_folder$manifest_doc
      cat $main_sls_file |  grep -E "^[[:space:]]+[[:alnum:]]+:[[:space:]]+[^{]"\|"^[[:space:]]+-[[:space:][:alnum:]:]+" | grep -v "\- name" | grep -v "\- pillar" | grep -v "\- mods" | grep -v "{" | grep -v  "sls" | grep -v "retry" | grep -v "attempts:" | grep -v "until:" | grep -v "interval:" | grep -v "splay" | grep -v "s_time" >> $output_folder$variables_doc
      echo $main_sls_file >> $output_folder$cmd_doc
      cat $main_sls_file |  grep -E -A1 "cmd.run" | grep -v "cmd.run" | grep -v "^\-\-" >> $output_folder$cmd_doc
      sed -i '$d' $output_folder$process_doc
   fi
   #echo "passing through the loop with values of \n FILE=$FILE \n FILENAME=$FILENAME \n FILELOC=$FILELOC \n"
   COUNT=$(cat $output_folder$process_doc | grep -E "\- mods:" | wc -l)
   echo "$COUNT yaml files left to parse....be patient, eddie wrote this script"
done
cat $output_folder$manifest_doc | sort | uniq > /tmp/temp_manifest && mv /tmp/temp_manifest $output_folder$manifest_doc 
linecount=$(cat $output_folder$process_doc | grep -E "^[[:alnum:]].*" | wc -l)
for(( i = 1; i <= $linecount; i++ )); do 
   #echo "$i is less than $linecount"
   sed -i "0,/^[a-zA-Z0-9][^STEP]/s//STEP $i - &/" $output_folder$process_doc;
done

slsFiles=$(find "$main_sls_path" -name *.sls)
#echo "find "$main_sls_path" -name *.sls"
#find "$main_sls_path" -name *.sls
unused_doc=$main_file"-"$cdate"-unused_slsFiles.doc"
touch $output_folder$unused_doc

for file in $slsFiles
do
  match=$(cat $output_folder$manifest_doc | grep "^$file$" | wc -l)
  if (( $match!=1 )); then
    echo $file >> $output_folder$unused_doc ;
  fi
done
