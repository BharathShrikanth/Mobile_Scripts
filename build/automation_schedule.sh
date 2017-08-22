#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$PATH:$DIR


API_KEY="wr243s65vt6th9s4txctftt3bh2999v8"	#User - prabhuraj
API_SECRET="dj7fwtbr36yrwyxzp8x478w4wmvn4766"		
domain="192.168.2.104"

device_count_phone=1
device_count_tablet=1
device_count_any=1

json_decode_token(){
	json=$1
	json_field=$2
	error=$(echo $json | jq '.result.error')
	if [ "$error" = "null" ]
		then 
			code=$(echo $json | jq '.result.code')
			if [ "$code" = "200" ]
				then
					access_token=$(echo $json | jq '.result.token' | sed 's:^.\(.*\).$:\1:')
					echo $access_token
					return 0
				else
					return 2
			fi
		else
			return 2
	fi 
}

json_decode_code(){
	json=$1
	json_field=$2
	error=$(echo $json | jq '.result.error')
	if [ "$error" = "null" ]
		then 
			code=$(echo $json | jq '.result.code')
			if [ "$code" = "200" ]
				then
					echo $code
					return 0
				else
					return 2
			fi
		else
			return 2
	fi 
}

json_decode_devices(){
	json=$1
	json_field=$2
	error=$(echo $json | jq '.result.error')
	if [ "$error" = "null" ]
		then 
			code=$(echo $json | jq '.result.code')
			if [ "$code" = "200" ]
				then
					devices=$(echo $json | jq '.result.devices[]')
					echo "$devices"
					return 0
				else
					return 2
			fi
		else
			return 2
	fi 
}

json_decode_status(){
	json=$1
	json_field=$2
	error=$(echo $json | jq '.result.error')
	if [ "$error" = "null" ]
		then 
			code=$(echo $json | jq '.result.code')
			if [ "$code" = "200" ]
				then
					status=$(echo $json | jq '.result.status')
					echo "$status"
					return 0
				else
					return 2
			fi
		else
			return 2
	fi 
}

json_decode_link(){
	json=$1
	error=$(echo $json | jq '.result.error')
	if [ "$error" = "null" ]
		then 
			code=$(echo $json | jq '.result.code')
			if [ "$code" = "200" ]
				then
					link=$(echo $json | jq '.result.link')
					echo "$link"
					return 0
				else
					return 2
			fi
		else
			return 2
	fi 
}

json_decode_cucumber_status(){
	json=$1
	error=$(echo $json | jq '.result.error')
	if [ "$error" = "null" ]
		then 
			code=$(echo $json | jq '.result.code')
			if [ "$code" = "200" ]
				then
					cucumber_status=$(echo $res | jq '.result.cucumber_status')
					echo $cucumber_status
					return 0
				else
					return 2
			fi
		else
			return 2
	fi 
}

check_substring(){
	str="$1"
	sub_str_phone="phone"
	sub_str_tablet="tablet"
	if echo "$str" | grep -q "$sub_str_phone"
		then
			echo "$sub_str_phone"
	elif echo "$str" | grep -q "$sub_str_tablet"
		then
			echo "$sub_str_tablet"
	else
		echo "no match"
	fi
}

api_call(){
	api=$1
	data="$2"
	
	header="Content-Type:application/json"
	res=$(curl -k -X POST -d "$data" $api 2> curl_result || echo "Error")
	echo $res
}

api_upload_file(){
	api=$1
	token=$2
	file_Type=$3
	file_name=$4
	
	res=$(curl -k -X POST -F "source_type=raw" -F "$file_Type=@$file_name" -F "token=$token" $api 2> curl_result || echo "Error")
	echo $res
}

get_access_token(){
	data="key=$API_KEY&secret=$API_SECRET"

	res=$(api_call $api_root_generate $data)
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
}

set_test_parms(){
	access_token=$1
	device_type=$2
	count=$3
	tst_parm="$4"
	data="token=$access_token&os=$os_value&test_type=1&device_type=$device_type&random=1&count=$count&extra_arg=$tst_parm"
	res=$(api_call $api_root_automate "$data")
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
	
}



upload_app_file(){
	access_token=$1
	app_file="$2"
	res=$(api_upload_file $api_root_automate $access_token "app" "$app_file")
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
	
}

upload_test_file(){
	access_token=$1
	test_file="$2"
	res=$(api_upload_file $api_root_automate $access_token "test" "$test_file")
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
	
}

schedule(){
	access_token=$1
	
	data="token=$access_token&schedule=1"
	res=$(api_call $api_root_automate $data)
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
}

get_status(){
	access_token=$1
	
	data="token=$access_token&full_status=1"
	res=$(api_call $api_root_automate $data)
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
}

get_cucumber_status(){
	access_token=$1
	dev=$2
	data="token=$access_token&cucumber_status=$dev"
	res=$(api_call $api_root_automate $data)
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
}

get_device_status(){
	access_token=$1
	dev=$2
	data="token=$access_token&status=$dev"
	res=$(api_call $api_root_automate $data)
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi
}

get_interactive_link(){
	access_token=$1
	
	data="token=$access_token&full_link=1"
	res=$(api_call $api_root_automate $data)
	if [ "$res" = "Error" ]
		then 
			return 2
	else		 
			echo "$res"
			return 0
	fi	
}

change_feature_name(){
	infile=$1
	append_text=$2
	outfile=$3
	
sed "/\"keyword\" *: *\"Feature\" *, *$/{
N
s/\"keyword\": \"Feature\",\n *\"name\" *: *\"/&$2- /"} <$1 >temp

sed "s/\"uri\": \"features\//&$2/" <temp >$3

rm temp
}

string_url_encoded(){
	str="$1"
	str_encoded=$(echo $str | sed 's:%:%25:g;s: :%20:g;s:+:%2B:g;s:<:%3C:g;s:>:%3E:g;s:#:%23:g;s:{:%7B:g;s:}:%7D:g;s:|:%7C:g;s:\\:%5C:g;s:\^:%5E:g;s:~:%7E:g;s:\[:%5B:g;s:\]:%5D:g;s:`:%60:g;s:;:%3B:g;s:/:%2F:g;s:?:%3F:g;s^:^%3A^g;s:@:%40:g;s:=:%3D:g;s:&:%26:g;s:\$:%24:g;s:\!:%21:g;s:\*:%2A:g')
	echo "$str_encoded"
}

show_help(){
	echo -e "\n"
	echo -e "Usage: bash api_console.sh --api_key=<api key> --api_secret=<api secret> --os=<android/ios> --app=<path to application> --phone_app=<path to application file for phone> --tablet_app=<path to application file for tablet> --script=<Path to test case file> --phone_script=<Path to test case file for phone> --tablet_script=<Path to test case file for tablet> --test_params=<Test Parameters> --phone_test_params=<Test Parameters for phone> --tablet_test_params=<Test Parameters for tablet> --no_devices=<Number of devices> --no_phones=<Number of phones> --no_tabs=<Number of tablets> "
	echo -e "\n"
	echo "--api_key		API KEY. It can be generated by logging in to device cloud."
	echo "--api_secret		API SECRET. It can be generated by logging in to device cloud."
	echo "--os			android or ios."
	echo "--app			Path to application file that can be installed both on phone and tablet."
	echo "--phone_app		Path to application file that can be installed only on phone."	
	echo "--tablet_app		Path to application file that can be installed only on tablet."
	echo "--script		Path to script file that can be used both for phone and tablet."
	echo "--phone_script		Path to script file that can be used only on phone."		
	echo "--tablet_script		Path to script file that can be used used only on tablet."	
	echo "--test_params		Test parameters for automation. Number of test parameters should be same as number of devices chosen."
	echo "--phone_test_params	Test parameters for automation on phone. Number of test parameters should be same as number of phones chosen."	
	echo "--tablet_test_params	Test parameters for automation on phone. Number of test parameters should be same as number of tablets chosen."
	echo "--no_devices		Number of devices on which Automation should run."
	echo "--no_phones		Number of phones on which Automation should run."	
	echo "--no_tablets		Number of tablets on which Automation should run."	
	echo -e "\n"
}

api_root_automate="https://$domain/api/automate"
api_root_generate="https://$domain/api/generate"

#array_position
phone=0
tablet=1
any=2

declare -a status

declare -a file_names_list
declare -a file_names_app
declare -a file_names_zip
declare -a test_params_list
declare -a file_available
declare -a automation_types

file_available[$phone]=0
file_available[$tablet]=0

automation_types[$phone]="phone"
automation_types[$tablet]="tablet"
automation_types[$any]="any"

#command_line_params

if [ $# = 0 ]
	then
		echo "Paramaters to script are missing"
		show_help
		exit 1
fi

for i in "$@"
do
		case $i in
		--os=*) 		
					value="${i#*=}"
					os="$value"
					if [ "$os" = "android" ]
						then
						app_type="apk"
						os_value=0
					elif [ "$os" = "ios" ]
						then
						app_type="ipa"
						os_value=1
					else
						echo "Unsupported app type"
						exit 1
					fi
					shift
					;;
		--app=*)
					file_names_app[$any]="${i#*=}"
					shift
					;;
		--script=*)
					file_names_zip[$any]="${i#*=}"
					shift
					;;
		--phone_app=*)
					file_names_app[$phone]="${i#*=}"
					shift
					;;
		--tablet_app=*)
					file_names_app[$tablet]="${i#*=}"
					;;
		--phone_script=*)
					file_names_zip[$phone]="${i#*=}"
					shift
					;;
		--tablet_script=*)
					file_names_zip[$tablet]="${i#*=}"
					shift
					;;
		--test_params=*)
					test_params_list[$any]=$(string_url_encoded "${i#*=}")
					shift
					;;
		--phone_test_params=*)
					test_params_list[$phone]=$(string_url_encoded "${i#*=}")
					shift
					;;
		--tablet_test_params=*)
					test_params_list[$tablet]=$(string_url_encoded "${i#*=}")
					shift
					;;
		--no_devices=*)
					device_count_any="${i#*=}"
					shift
					;;
		--no_phones=*)
					device_count_phone="${i#*=}"
					shift
					;;
		--no_tabs=*)
					device_count_tablet="${i#*=}"
					shift
					;;
		--api_key=*)
					API_KEY="${i#*=}"
					shift
					;;
		--api_secret=*)
					API_SECRET="${i#*=}"
					shift
					;;
		--help)
					show_help
					exit 1
					;;
			*)			
				echo "Wrong Paramaters to script"
				show_help
				exit 1
				;;
		esac
	done

#status
not_started=0
running=1
pass=2
fail=3
cancel=4
completed=5

access_token_phone=""
access_token_tablet=""
access_token_any=""

phone_automations=0
tablet_automations=0
any_automations=0

phone_automation_status=0
tablet_automation_status=0
any_automation_status=0

device_list_phone=""
device_list_tablet=""
device_list_any=""

previous_stat_phone="-1"
previous_stat_tablet="-1"
previous_stat_any="-1"

total_automations=0
automations_completed=0

echo "${file_names_app[*]}"
echo "${file_names_zip[*]}"
echo "${test_params_list[*]}"

for (( i=0; i < 3; i++ ))
	do
		if [ -z "${test_params_list[$i]}" ]
			then
			if [ ! -z "${file_names_app[$i]}" ] || [ ! -z "${file_names_zip[$i]}" ]
			then
				echo "Test Params missing"
				exit 1
			fi
		fi
		if [ -z "${file_names_zip[$i]}" ] 
			then
			if [ ! -z "${file_names_app[$i]}" ] || [ ! -z "${test_params_list[$i]}" ]	
				then
				echo "Zip missing"
				exit 1
			fi
		fi
		if [ -z "${file_names_app[$i]}" ] 
			then
				if [ ! -z "${test_params_list[$i]}" ] || [ ! -z "${file_names_zip[$i]}" ]	
				then
				echo "App missing"
				exit 1
			fi
		fi
	done

for (( i=0; i < 3; i++ ))
	do
		if [ ! -z "${file_names_app[$i]}" ] && [ ! -z "${file_names_zip[$i]}" ] && [ ! -z "${test_params_list[$i]}" ]
		then
			case_var="${automation_types[$i]}"
			case $case_var in
				
				"phone")			
						api_result=$(get_access_token)							
						if [ $? = 2 ]
							 then
								echo "Error Getting access token. May be connection Problem"
								exit 1
						else
								access_token_phone=$(json_decode_token $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								else
										echo "Access Token Generated - $access_token_phone"
								fi
						fi
						
						api_result=$(set_test_parms $access_token_phone "phone" $device_count_phone "${test_params_list[$i]}")
						if [ $? = 2 ]
							then
								echo "Error setting automation parameters. May be connection Problem"
								exit 1
						else 						 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
										echo "Automation Parameters are set!"
								fi
								
						fi
						
						echo "${file_names_no_extention[$i]}"
						api_result=$(upload_app_file $access_token_phone "${file_names_app[$i]}")
						if [ $? = 2 ]
							then
								echo "Error uploading app file. May be connection Problem"
								exit 1
						 else
							 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
									 
										echo "App File Uploaded!"
								fi
						fi
						
						api_result=$(upload_test_file $access_token_phone "${file_names_zip[$i]}")
						if [ $? = 2 ]
							then
								echo "Error uploading test file. May be connection Problem"
								exit 1
						 else
							 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
										phone_automations=$(($phone_automations+1))
										echo "Test File Uploaded!"
								fi
						fi
						
						;;
				"tablet")			
						api_result=$(get_access_token)							
						if [ $? = 2 ]
							then
								echo "Error Getting access token. May be connection Problem"
								exit 1
						 else
							 
								access_token_tablet=$(json_decode_token $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
									 
										echo "Access Token Generated - $access_token_tablet"
								fi
						fi
						
						api_result=$(set_test_parms $access_token_tablet "tablet" $device_count_tablet "${test_params_list[$i]}")
						if [ $? = 2 ]
							then
								echo "Error setting automation parameters. May be connection Problem"
								exit 1
						 else
							 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
									 
										echo "Automation Parameters are set!"
								fi
						fi
						echo "${file_names_no_extention[$i]}"
						api_result=$(upload_app_file $access_token_tablet "${file_names_app[$i]}")
						if [ $? = 2 ]
							then
								echo "Error uploading app file. May be connection Problem"
								exit 1
						 else
							 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
									 
										echo "App File Uploaded!"
								fi
						fi
						
						api_result=$(upload_test_file $access_token_tablet "${file_names_zip[$i]}")
						if [ $? = 2 ]
							then
								echo "Error uploading test file. May be connection Problem"
								exit 1
						 else						 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
										tablet_automations=$(($tablet_automations+1))
										echo "Test File Uploaded!"
								fi
						fi
						
						;;
				"any")				
						api_result=$(get_access_token)							
						if [ $? = 2 ]
							 then
								echo "Error Getting access token. May be connection Problem"
								exit 1
						else
								access_token_any=$(json_decode_token $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								else
										echo "Access Token Generated - $access_token_any"
								fi
						fi
						
						api_result=$(set_test_parms $access_token_any "any" $device_count_any "${test_params_list[$i]}")
						if [ $? = 2 ]
							then
								echo "Error setting automation parameters. May be connection Problem"
								exit 1
						else 
							 
								code=$(json_decode_code $api_result)
								#echo $?
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
										echo "$code"
										echo "Automation Parameters are set!"
								fi
								
						fi
						
						api_result=$(upload_app_file $access_token_any "${file_names_app[$i]}")
						if [ $? = 2 ]
							then
								echo "Error uploading app file. May be connection Problem"
								exit 1
						 else
							 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
									 
										echo "App File Uploaded!"
								fi
						fi
						
						api_result=$(upload_test_file $access_token_any "${file_names_zip[$i]}")
						if [ $? = 2 ]
							then
								echo "Error uploading test file. May be connection Problem"
								exit 1
						 else
							 
								code=$(json_decode_code $api_result)
								if [ $? = 2 ]
									then
										echo "API returned error"
										echo "$api_result"
										exit 1
								 else
										any_automations=$(($any_automations+1))
										echo "Test File Uploaded!"
								fi
						fi
					;;

				*)					
						echo "malformed file names"
						exit 1			#How to exit if one file has malformed name
						;;
			esac
		fi
	done

if [ $phone_automations = 1 ]
	then
		api_result=$(schedule $access_token_phone)
		if [ $? = 2 ]
			then
				echo "Error while scheduling. May be connection Problem"
				exit 1
		 else		 
			devices=$(json_decode_devices $api_result)
			if [ $? = 2 ]
				then
					echo "API returned error"
					echo "$api_result"
					exit 1
			 else
				 
					echo -e "\nAutomation Scheduled! Phone List:"
					echo -e "$devices\n"
					device_list_phone="$devices"
					
			fi
		fi
fi
if [ $tablet_automations = 1 ]
	then
		api_result=$(schedule $access_token_tablet)
		if [ $? = 2 ]
			then
				echo "Error while scheduling. May be connection Problem"
				exit 1
		 else		 
			devices=$(json_decode_devices $api_result)
			if [ $? = 2 ]
				then
					echo "API returned error"
					echo "$api_result"
					exit 1
			 else
				 
					echo -e "\nAutomation Scheduled! Tablet List:"
					echo -e "$devices\n"
					device_list_tablet="$devices"
					
			fi
		fi					
fi
if [ $any_automations = 1 ]
	then
	api_result=$(schedule $access_token_any)
	if [ $? = 2 ]
		then
			echo "Error while scheduling. May be connection Problem"
			exit 1
	 else	 
		devices=$(json_decode_devices $api_result)
		if [ $? = 2 ]
			then
				echo "API returned error"
				echo "$api_result"
				exit 1
		 else
			 
				echo -e "\nAutomation Scheduled! tablet/phone List:"
				echo -e "$devices\n"
				device_list_any="$devices"
		fi
	fi					
fi
	
	total_automations=$(($phone_automations+$tablet_automations+$any_automations))
	
	while [ $total_automations != $automations_completed ]
		do
			if [ ! -z  $access_token_phone ] && [ $phone_automation_status -lt 2 ]
				then
					api_result=$(get_status $access_token_phone)
					if [ $? = 2 ]
						then
							echo "Error getting status. May be connection Problem"
							exit 1
					 else					 
							phone_automation_status=$(json_decode_status $api_result)
							if [ $? = 2 ]
								then
									echo "API returned error"
									echo "$api_result"
									exit 1
							 else
								if [ "$previous_stat_phone" != "$phone_automation_status" ] #This condition restricts printing result json only on ststus change
									then
									previous_stat_phone=$phone_automation_status
									if [ $phone_automation_status = $not_started ]
										then
											echo "Automation on phone is not started"
									elif [ $phone_automation_status = $running ]
										then
											echo "Automation on phone is running"
									elif [ $phone_automation_status = $pass ]
										then
											echo "Automation on phone is completed"
											automations_completed=$(($automations_completed+1))
									elif [ $phone_automation_status = $fail ]
										then
											echo "Automation on phone is failed"
											automations_completed=$(($automations_completed+1))
									elif [ $phone_automation_status = $cancel ]
										then
											echo "Automation on phone is cancled"
											automations_completed=$(($automations_completed+1))
									fi
								fi
							fi
					fi
			fi
			
			if [ ! -z  $access_token_tablet ] && [ $tablet_automation_status -lt 2 ]
				then
					api_result=$(get_status $access_token_tablet)
					if [ $? = 2 ]
						then
							echo "Error getting status. May be connection Problem"
							exit 1
					 else						 
							tablet_automation_status=$(json_decode_status $api_result)
							if [ $? = 2 ]
								then
									echo "API returned error"
									echo "$api_result"
									exit 1
							 else							 
								if [ "$previous_stat_tablet" != "$tablet_automation_status" ] #This condition restricts printing result json only on ststus change
									then
									previous_stat_tablet=$tablet_automation_status								
									if [ $tablet_automation_status = $not_started ]
										then
											echo "Automation on tablet is not started"
									elif [ $tablet_automation_status = $running ]
										then
											echo "Automation on tablet is running"
									elif [ $tablet_automation_status = $pass ]
										then
											echo "Automation on tablet is completed"
											automations_completed=$(($automations_completed+1))
									elif [ $tablet_automation_status = $fail ]
										then
											echo "Automation on tablet is failed"
											automations_completed=$(($automations_completed+1))
									elif [ $tablet_automation_status = $cancel ]
										 then
											echo "Automation on tablet is cancled"
											automations_completed=$(($automations_completed+1))
									fi
								fi
							fi
					fi
			fi
			
			if [ ! -z  $access_token_any ] && [ $any_automation_status -lt 2 ]
				then
					api_result=$(get_status $access_token_any)
					if [ $? = 2 ]
						then
							echo "Error getting status. May be connection Problem"
							exit 1
					 else						 
							any_automation_status=$(json_decode_status $api_result)
							if [ $? = 2 ]
								then
									echo "API returned error"
									echo "$api_result"
									exit 1
							 else							 
									if [ "$previous_stat_any" != "$any_automation_status" ] #This condition restricts printing result json only on ststus change
										then
										previous_stat_any=$any_automation_status								
										if [ $any_automation_status = $not_started ]
											then
												echo "Automation on tablet/phone is not started"
										elif [ $any_automation_status = $running ]
											then
												echo "Automation on tablet/phone is running"
										elif [ $any_automation_status = $pass ]
											then
												echo "Automation on tablet/phone is completed"
												automations_completed=$(($automations_completed+1))
										elif [ $any_automation_status = $fail ]
											then
												echo "Automation on tablet/phone is failed"
												automations_completed=$(($automations_completed+1))
										elif [ $any_automation_status = $cancel ]
											 then
												echo "Automation on tablet/phone is cancled"
												automations_completed=$(($automations_completed+1))
										fi
									fi
							fi
					fi
			fi
			if [ $total_automations != $automations_completed ]
				then
					sleep 120
			fi
		done

mkdir -p Device_cucumber_json_reports

if [ ! -z  $access_token_phone ] && [ $phone_automation_status = 2 ]
	then
		sleep 60
		data="token=$access_token_phone&full_pdf=1"
		curl -k -X POST -d $data -o "Report_phone.pdf" $api_root_automate
		
		mkdir -p Device_cucumber_json_reports/phone
		n=$(echo $device_list_phone | awk '{print NF}')
		echo $device_list_phone
		i=0
		while [[ $n -gt $i ]]
			do
				coloum=$(($n-$i))
				dev_name=$(echo $device_list_phone | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')				
				data="token=$access_token_phone&json_report=$dev_name"
				curl -k -X POST -d $data -o "Device_cucumber_json_reports/phone/$dev_name.json" $api_root_automate
				json_file="Device_cucumber_json_reports/phone/$dev_name.json"
				change_feature_name "$json_file" "$dev_name" "$json_file"
				i=$(($i+1))
			done
			
fi

if [ ! -z  $access_token_tablet ] && [ $tablet_automation_status = 2 ]
	then
		sleep 60
		data="token=$access_token_tablet&full_pdf=1"
		curl -k -X POST -d $data -o "Report_tablet.pdf" $api_root_automate
		
		mkdir -p Device_cucumber_json_reports/tablet
		n=$(echo $device_list_tablet | awk '{print NF}')
		echo $device_list_tablet
		i=0
		while [[ $n -gt $i ]]
			do
				coloum=$(($n-$i))
				dev_name=$(echo $device_list_tablet | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
				data="token=$access_token_tablet&json_report=$dev_name"
				curl -k -X POST -d $data -o "Device_cucumber_json_reports/tablet/$dev_name.json" $api_root_automate
				json_file="Device_cucumber_json_reports/tablet/$dev_name.json"
				change_feature_name "$json_file" "$dev_name" "$json_file"
				i=$(($i+1))
			done
			
fi

if [ ! -z  $access_token_any ] && [ $any_automation_status = 2 ]
	then
		sleep 60
		data="token=$access_token_any&full_pdf=1"
		curl -k -X POST -d $data -o "Report_any.pdf" $api_root_automate
		
		mkdir -p Device_cucumber_json_reports/any
		n=$(echo $device_list_any | awk '{print NF}')
		echo $device_list_any
		i=0
		while [[ $n -gt $i ]]
			do
				coloum=$(($n-$i))
				dev_name=$(echo $device_list_any | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')				
				data="token=$access_token_any&json_report=$dev_name"
				curl -k -X POST -d $data -o "Device_cucumber_json_reports/any/$dev_name.json" $api_root_automate
				json_file="Device_cucumber_json_reports/any/$dev_name.json"
				change_feature_name "$json_file" "$dev_name" "$json_file"
				i=$(($i+1))
			done
			
fi

if [ $phone_automation_status -gt 2 ]
	then
		n=$(echo $device_list_phone | awk '{print NF}')
		i=0
		while [[ $n -gt $i ]]
			do
				coloum=$(($n-$i))
				dev_name=$(echo $device_list_phone | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
				api_result=$(get_device_status $access_token_phone $dev_name)
				if [ $? = 2 ]
					then
						echo "Error setting status for $dev_name. May be connection Problem"
				 else				 
						status=$(json_decode_status $api_result)
						if [ $? = 2 ]
							then
								echo "Error setting status for $dev_name."
								echo $api_result
							else
								if [ $status = 2 ]
									then
										echo "Automation Passed on $dev_name"
									elif [ $status = 3 ]
										then
											echo "Automation failed on $dev_name"
									elif [ $status = 4 ]
										then
											echo "Automation cancled on $dev_name"
								fi
						fi
				fi
				i=$(($i+1))
			done
fi

if [ $tablet_automation_status -gt 2 ]
	then
		n=$(echo $device_list_tablet | awk '{print NF}')
		i=0
		while [[ $n -gt $i ]]
			do
				coloum=$(($n-$i))
				dev_name=$(echo $device_list_tablet | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
				api_result=$(get_device_status $access_token_tablet $dev_name)
				if [ $? = 2 ]
					then
						echo "Error setting status for $dev_name. May be connection Problem"
				 else				 
						status=$(json_decode_status $api_result)
						if [ $? = 2 ]
							then
								echo "Error setting status for $dev_name."
								echo $api_result
							else
								if [ $status = 2 ]
									then
										echo "Automation Passed on $dev_name"
									elif [ $status = 3 ]
										then
											echo "Automation failed on $dev_name"
									elif [ $status = 4 ]
										then
											echo "Automation cancled on $dev_name"
								fi
						fi
				fi
				i=$(($i+1))
			done
fi

if [ $any_automation_status -gt 2 ]
	then
		n=$(echo $device_list_any | awk '{print NF}')
		i=0
		while [[ $n -gt $i ]]
			do
				coloum=$(($n-$i))
				dev_name=$(echo $device_list_any | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
				api_result=$(get_device_status $access_token_any $dev_name)
				if [ $? = 2 ]
					then
						echo "Error setting status for $dev_name. May be connection Problem"
				 else				 
						status=$(json_decode_status $api_result)
						if [ $? = 2 ]
							then
								echo "Error setting status for $dev_name."
								echo $api_result
							else
								if [ $status = 2 ]
									then
										echo "Automation Passed on $dev_name"
									elif [ $status = 3 ]
										then
											echo "Automation failed on $dev_name"
									elif [ $status = 4 ]
										then
											echo "Automation cancled on $dev_name"
								fi
						fi
				fi
				i=$(($i+1))
			done
fi

mkdir -p Cucumber_console

if [ ! -z  $access_token_phone ] && [ $phone_automation_status -lt $cancel ]
	then
		mkdir -p Cucumber_console/phone
		n=$(echo $device_list_phone | awk '{print NF}')
			i=0
			while [[ $n -gt $i ]]
				do
					coloum=$(($n-$i))
					dev_name=$(echo $device_list_phone | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
					data="token=$access_token_phone&stdout=$dev_name"
					curl -k -X POST -d $data -o "Cucumber_console/phone/$dev_name.txt" $api_root_automate
					i=$(($i+1))
				done
		echo -e "\n"
		api_result=$(get_interactive_link $access_token_phone)
		if [ $? = 2 ]
		then
			echo "Error getting link for interactive report. May be connection Problem"
		else				 
			link=$(json_decode_link $api_result)
			if [ $? = 0 ]
				then
					echo "Link for Phone Interactive report - $link"
			fi
		fi
fi

if [ ! -z  $access_token_tablet ] && [ $tablet_automation_status -lt $cancel ]
	then
		mkdir -p Cucumber_console/tablet
		n=$(echo $device_list_tablet | awk '{print NF}')
			i=0
			while [[ $n -gt $i ]]
				do
					coloum=$(($n-$i))
					dev_name=$(echo $device_list_tablet | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
					data="token=$access_token_tablet&stdout=$dev_name"
					curl -k -X POST -d $data -o "Cucumber_console/tablet/$dev_name.txt" $api_root_automate
					i=$(($i+1))
				done
		echo -e "\n"
		api_result=$(get_interactive_link $access_token_tablet)
		if [ $? = 2 ]
		then
			echo "Error getting link for interactive report. May be connection Problem"
		else				 
			link=$(json_decode_link $api_result)
			if [ $? = 0 ]
				then
					echo "Link for Tablet Interactive report - $link"
			fi
		fi
fi

if [ ! -z  $access_token_any ] && [ $any_automation_status -lt $cancel ]
	then		
		mkdir -p Cucumber_console/any
		n=$(echo $device_list_any | awk '{print NF}')
			i=0
			while [[ $n -gt $i ]]
				do
					coloum=$(($n-$i))
					dev_name=$(echo $device_list_any | awk -v f="$coloum" '{print $f}' | sed 's:^.\(.*\).$:\1:')
					data="token=$access_token_any&stdout=$dev_name"
					curl -k -X POST -d $data -o "Cucumber_console/any/$dev_name.txt" $api_root_automate
					i=$(($i+1))
				done
		echo -e "\n"
		api_result=$(get_interactive_link $access_token_any)
		if [ $? = 2 ]
		then
			echo "Error getting link for interactive report. May be connection Problem"
		else				 
			link=$(json_decode_link $api_result)
			if [ $? = 0 ]
				then
					echo "Link for Tablet Interactive report - $link"
			fi
		fi
fi

echo -e "\n"
if [ $phone_automation_status -gt 2 ] || [ $tablet_automation_status -gt 2 ] || [ $any_automation_status -gt 2 ]
	then
		exit 1
fi


