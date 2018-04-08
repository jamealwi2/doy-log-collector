#!/bin/bash

#===================================================================================
#
# FILE: collect-doy-drillbitlog.sh
#
# USAGE: collect-doy-drillbitlog.sh [-a application-id] [-d destination-directory] [-h]
#
# DESCRIPTION: The script helps to collect Drill On YARN (DOY) application log for a 
# running DOY cluster. The script identifies the container IDs where drillbit is 
# running and then copying the file to the desired location from every node where 
# drill bits are launched. 
#
# OPTIONS: see function 'usage' below
# NOTES: Change the 'hadoop-2.7.0' version to appropriate version as required.
# AUTHOR: Alwin James, jamealwi@gmail.com
# VERSION: 1.0
# CREATED: 02.26.2018
#===================================================================================


usage(){
echo "Please see usage below:"
echo "collect-doy-drillbitlog.sh -a <application id> -d <copy destination>"
echo "collect-doy-drillbitlog.sh -a <application id> (Default copy destination is '/tmp'.)"
}

while getopts 'ha:d:' option; do
        case "$option" in
                h) usage
                        exit
                        ;;
                a) application_id=$OPTARG
                        ;;
                d) copy_location=$OPTARG
                        ;;
        esac
done;

if [ -z $application_id ]; then
        echo "Please specify the application ID."
  usage
        exit
fi

if [ -z $copy_location ]; then
        echo "Copy destination location not specified. The log will be copied to '/tmp'."
        echo -n "Please confirm: (y/n)? "
        read answer
        if echo "$answer" | grep -iq "^y" ;then
                copy_location="/tmp"
        else
                exit
        fi
fi

ls /opt/mapr/hadoop/hadoop-2.7.0/logs/userlogs/${application_id}/*/* |grep drillbit.log | while read line
do container_id=$(echo $line | awk -F"/" '{print $(NF-1)}')
cp $line /${copy_location}/`hostname`-${container_id}-drillbit.log
done;
