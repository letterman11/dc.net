#!/usr/bin/bash

#set -x

#--------------------------------------------------------------
# script: aserver_menu.sh				        
# purpose: script for setting database config of various apps   
# to the www.dcoda.net web site				       
#--------------------------------------------------------------

AZURE="AZURE_MYSQL"
AWS="AWS_MYSQL"
ALI="ALIBABA_MYSQL"
SQLITE="SQLITE"

A1="ALL"
A2="Classic" 
A3="NEW"   
A4="SOME"   

declare -A db_map=([1]="AZURE_MYSQL" [2]="AWS_MYSQL" [3]="SQLITE" [4]="ALIBABA_MYSQL")
declare -A env_map=(["A"]=$A1 ["C"]=$A2 ["N"]=$A3 ["S"]=$A4)

declare -a apps=("STOCKAPP" "WEBMARKS" "CHATBOX" "POLLCENTER" "WEBMARKS_PY" "WEBMARKS_BETA" "WEBMARKS_DELTA" "EXPRESSCHAT")

CONFIG_FILE=$HOME/bin/stockDbConfig.cfg

##########
#function#
##########
function main()
{
    typeset b 
    main_menu_start
    read b

    case $b in
		1) 
		menu_db_select "A"
		;;
		2)
		menu_db_select "C"
		;;
		3)
		menu_db_select "N"
		;;
		4)
		menu_some_select 
		;;
    esac

}

##########
#function#
##########
function main_menu_start() 
{
    clear

cat <<END_MSG
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@  APPS DATABASE PROGRAM @@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

1) ALL APPS     
2) ALL Classic APPS 
3) NEW APPS   
4) SOME APPS   

END_MSG

}


##########
#function#
##########
function menu_db_select()
{
	clear

cat<<END_MSG
$1
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@  DATABASE SELECTION       @@@@   
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

1) Azure Mysql DB
2) AWS Mysql VM Instance 
3) local SQLite3 DB
4) Alibaba MySQL DB

END_MSG

    typeset b
    read b

    DB=$b

    case $1 in
        "A" | $A1)
        menu_exec "A" $DB  
        ;;
        "C" | $A2)
        menu_exec "C" $DB
        ;;
        "N" | $A3)
        menu_exec "N" $DB 
        ;;
        "S" | $A4)
        menu_exec "S" $DB $(($2 - 1))
        ;;
    esac

}

##########
#function#
##########
function menu_some_select() 
{
cat<<END_MSG
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@  NEW APPS OR OLD  MENU @@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

1) CLASSIC APPS     
2) NEW APPS   

END_MSG

    typeset b

    read b
    case $b in
        1) 
        menu_classic_apps  
        ;;
        2)
        menu_new_apps
        ;;
     esac
}


##########
#function#
##########
function menu_new_apps() 
{

cat<<END_MSG
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@  NEW APPS Database  MENU  @@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

1) WEBMARKS  
2) WEBMARKS BETA 
3) WEBMARKS DELTA
4) EXPRESSCHAT 

END_MSG

    typeset b
    read b
                    #env #app
                    #1   2
    menu_db_select $A4 $(($b + 4))

}

##########
#function#
##########
function menu_classic_apps() 
{

cat<<END_MSG
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@   CLASSIC APPS MENU    @@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

1) STOCKQUERY    
2) WEBMARKS
3) CHATBOX
4) POLLCENTER

END_MSG

    typeset b
    read b

    menu_db_select $A4 $b
}

##########
#function#
##########
function menu_exec()
{


cat<<END_MSG
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@  ${env_map[$1]} ${db_map[$2]} ${apps[${3:-100}]}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
END_MSG

    ENV_SEL=$1
    DB_SEL=${db_map[$2]}
    APP_SEL=$3

    if [[  -z $APP_SEL ]];then
    echo "HERE"
        $HOME/bin/server_menu.pl --app-sel ${env_map[$1]} --db-sel $DB_SEL --app-file $HOME/bin/dcoda_app.cfg #all apps
    else
        $HOME/bin/server_menu.pl --app-sel ${env_map[$1]} --db-sel $DB_SEL --app-file $HOME/bin/dcoda_app.cfg --app ${apps[$APP_SEL]} #all apps
    fi
          
}

#  ${arr[@]:s:n}

######
#main#
######

clear
main
