#!/bin/bash

installpath=/app/
tenant=apptest

######################
#CHANGE FOR NEW FLOWS TO BE ADDED
######################

declare -a deployfile=(
$installpath'inventoryappflow.jar'
$installpath'helper-1.0-SNAPSHOT.jar'
)

declare -a deploysoa=(
'InventoryAppFlow.soa'
'TransitionHelperFlow.soa'
)

######################
#CHANGE FOR NEW FLOWS TO BE ADDED
######################

defenabled='TransitionHelperFlow'
defenablefeatures="all"

declare -a enableflows=(
'InventoryAppFlow'
)

declare -a enablefeatures=(
'all'
)

declare -a enablelinks=(
''
)

