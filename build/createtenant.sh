#!/bin/bash

dirname=`dirname $0`
source $dirname/helperfunctions.sh
source /app/deployvars.sh

#####################
#DECLARE VARIABLES USED TO SETUP
######################

server=$1
port=$2
demodomain='*'

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
[ "$#" -ge 2 ] || die "Usage: createtenant server port"

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

defflow=$defenabled
efeatures=$defenablefeatures
echo "[Creating Tenant "$tenant" in domain "$demodomain"...]"
json=`postjson $smartowner $adminflow $newtenantevt "{'TenantAdmin':{'___smart_action___':'lookup','___smart_value___':'"$smartowner"' },'enableFeatures':[ '"$efeatures"' ],'enableFlow':'"$defflow"','tenant':'"$tenant"','domain':'"$demodomain"','clientOf':'SMART'}" $sessid`
message=`jsonval "$json" $depsrch`
[ ! -z "$message" ] || die "Cannot create tenant "$tenant" with domain "$demodomain" Error "$json
echo "[Created Tenant "$tenant" in domain "$demodomain"...]"
echo ""

################################################
# School Tenant
################################################

echo "[Enabling Flows...]"
for e in "${!enableflows[@]}"
do
    eflow=${enableflows[$e]}
    efeatures=${enablefeatures[$e]}
    elinks=${enablelinks[$e]}
    addlink=''
    if [ ! -z $elinks ]
    then
        addlink=",'links':$elinks"
    fi

    echo  '[Enabling Flow '$eflow' ...]'
    json=`postjson $smartowner $adminflow $enableevt "{'TenantAdmin':{'___smart_action___':'lookup','___smart_value___':'"$smartowner"'}, 'tenant':'"$tenant"','enableFeatures':[ '"$efeatures"' ],'enableFlow':'"$eflow"'"$addlink"}" $sessid`
    message=`jsonval "$json" $depsrch`
    [ ! -z "$message" ] || die "Cannot deploy file "$eflow" for "$efeatures" error "$json
    echo '[Enabled Flow '$eflow '...]'
done
echo "[Enabled All Flows...]"
echo ""

echo "[Authenticating as $tenant ...]"
json=`postjson $tenant $secflow $authevt "{'FlowAdmin':{'___smart_action___':'lookup', '___smart_value___':'"$secflow"'},'identity':'"$tenant"admin', 'password':'"$tenant"admin', 'type':'custom'}"`
sessid=`jsonval "$json" $sessrch`
[ ! -z "$sessid" ] || die "Cannot authenticate with server"
echo "[Authenticated Got sessionid: "$sessid"]"
echo ""


