#!/bin/bash

dirname=`dirname $0`
source $dirname/helperfunctions.sh
source /app/deployvars.sh

#####################
#DECLARE VARIABLES USED TO SETUP
######################

server=$1
port=$2
demodomain='localhost'

smartadm='smartadmin'
smartadmpwd='smartadmin'

######################
#CHANGE FOR DATA SETUP
######################


##############################
# SMART RELATED VARS
###############################

smartowner='SmartOwner'
adminflow='AdminSmartFlow'
secflow='Security'
authevt='Authenticate'
createusr='CreateUser'
addident='AddIdentity'
depevt='DeployEvent'
sessrch='sessionId'
depsrch='success'
newtenantevt='NewTenant'
enableevt='EnableFlow'
createrole='CreateRole'
msgsrch='message'
cfgevt='ConfigFlow'
adminevt='CreateAdminProfile'
chgpwd='ChangePassword'
createprime='CreatePrime'


################################
#CHECK ALL REQUIRED DATA IS PRESENT
################################
echo "[Checking parameters...]"
[ "$#" -ge 2 ] || die "Usage: deploy server port "
[ -d "$installpath" ] || die "Install path $dir does not exist"

for deploy in "${!deployfile[@]}"
do
    file=${deployfile[$deploy]}
    IFS=', ' read -a jarfiles <<< "$file"
    for element in "${jarfiles[@]}"
    do
        [ -e "$element" ] || die "File $element does not exist for deployment "
    done
done
echo "[Checked parameters...]"

##################################
#Authenticate 
###############################

echo ""
echo "[Authenticating as smartadmin...]"
json=`postjson $smartowner $secflow $authevt "{'FlowAdmin':{'___smart_action___':'lookup', '___smart_value___':'"$secflow"'},'identity':'"$smartadm"', 'password':'"$smartadmpwd"', 'type':'custom'}"`
sessid=`jsonval "$json" $sessrch`
[ ! -z "$sessid" ] || die "Cannot authenticate with server"

echo "[Authenticated Got sessionid: "$sessid"]"
echo ""

echo "[Deploying Flows ...]"
for deploy in "${!deployfile[@]}"
do
    file=${deployfile[$deploy]}
    soafile=${deploysoa[$deploy]}
    echo  '[Deploying '$soafile' from '$file' ...]'
    json=`postjson $smartowner $adminflow $depevt "{'TenantAdmin':{'___smart_action___':'lookup','___smart_value___':'"$smartowner"'}, 'deployJar':'"$file"','flowsoa':'"$soafile"'}" $sessid `
    message=`jsonval "$json" $depsrch`
    [ ! -z "$message" ] || die "Cannot deploy file "$file" for "$soafile" Error "$json
    echo '[Deployed '$soafile '...]'
done
echo "[Deployed Flows ...]"
echo ""

