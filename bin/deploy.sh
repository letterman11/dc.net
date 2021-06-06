#!/bin/sh

#set -x
#--------------------------------------------------------------#
# script: deploy.sh					       # 
# purpose: script for the deployment of various apps to the    #
# www.dcoda.net web site 				       #
#--------------------------------------------------------------#


##########
#cmd line#
##########
APP1=$1

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ REAL PRODUCTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#PROD_ROOT_PATH=/html
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

PROD_ROOT_PATH=/home/abrooks/www/staging/html
PROD_APP_PATH=/html/${APP1}

############
#hard codes#
############
#PROGRAM   change for production
TAR=/bin/tar;
CP=/bin/cp
MKDIR=/bin/mkdir
CHMOD=/bin/chmod
LINK=/bin/ln
MV=/bin/mv

######
#DATA#
######
SRC_FILES="js htm cgi css pm pl";
DIR=

###################
#regex/string subs#
###################

#### cookie path replacement
ONEOFF1_PAT="'/stockApp'"
ONEOFF1_REP_PAT="'/cgi-bin/stockApp'"


CGI_BIN_TEXT_REP=/${APP1}/cgi-bin
CGI_BIN_TEXT_SUB=/cgi-bin/${APP1}/cgi-bin

REP_LIB_PAT1="^use lib.*$"
REP_REQ_PAT2="^require.*$"

URL_PROD_PAT=http://localhost:8081
URL_HOME_PAT=http://localhost:8080

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ REAL PRODUCTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#PROD_SUB_LIB="use lib '/services/webpages/util/o/c/octagonyellow.site.aplus.net/html/${APP1}/script_src';"
#PROD_SUB_REQ="require '/services/webpages/util/o/c/octagonyellow.site.aplus.net/cgi-bin/${APP1}/cgi-bin/config.pl';"
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

PROD_SUB_LIB="use lib '/home/abrooks/www/staging/html/${APP1}/script_src';"
PROD_SUB_REQ="require '/home/abrooks/www/staging/cgi-bin/${APP1}/cgi-bin/config.pl';"
#======================================================================

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ REAL PRODUCTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#PROD_CGI_BIN=/cgi-bin
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

PROD_CGI_BIN=/home/abrooks/www/staging/cgi-bin


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ REAL PRODUCTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#PROD_SUB_POLLSESSIONS_DIR=/services/webpages/util/o/c/octagonyellow.site.aplus.net/html/pollCenter/sessions
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
REP_POLLSESSIONS_DIR=/home/abrooks/www/pollCenter/sessions
PROD_SUB_POLLSESSIONS_DIR=/home/abrooks/www/staging/html/pollCenter/sessions


##########
#function#
##########
cleanCVS()
{
   find . -name CVS -type d -exec rm -R {} \; 2> /dev/null;
}

##########
#function#
##########
err_display()
{
   echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   echo $1
   echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   echo
   echo
}

##########
#function#
##########
display()
{
   echo "**********************************"
   echo "**********************************"
   echo $1
   echo "*********************************"
   echo "**********************************"
   echo
   echo
}

##########
#function#
##########
warn()
{
   case $1 in
     11) err_display "Directory not found";;
     12) err_display "Cannot find unpacked application";;
      1) err_display  "General error";;
      *) err_display "Undefined error";;
   esac
   echo $1
}

##########
#function#
##########
error()
{
   case $1 in
     11) err_display "Directory not found";;
     12) err_display "Cannot find unpacked application";;
      1) err_display  "General error";;
      *) err_display "Undefined error";;
   esac
   exit $1
}



##########
#function#
##########
usage()
{
   echo '
deploy.sh <application> [pack|unpack|help]
		  pack		tar files in directory specified by <application>
		  unpack 	untar files in archive application.tar
		  help		shows this message
	'
exit 0;
}

##########
#function#
##########
pack_app()
{
   if  [ ! -d $APP1 ]; then
      error 11
   fi

   $TAR -cvf $APP1.tar $APP1 
   retCode=$?
   return $retCode
}

##########
#function#
##########
unpack_app()
{

   display "${APP1} - unpack_app"

   $TAR -xvf $APP1.tar  1> /dev/null
   cd $APP1
   cleanCVS
}

##########
#function#
##########
regsub()
{
   perl -e '
	   open(FH, "< $ARGV[0]") or die "Failed open $!";
	   my @lines = <FH>; 
	   close FH;

	   open(FH, "+> $ARGV[0]") or die "Failed open $!";

	   for(@lines)
	   {
		s#$ARGV[1]#$ARGV[2]#g;
		print FH $_;
	   }
	   close FH;

   ' $1 "$2" "$3"
}

##########
#function#
##########
replace_texts()
{
   display "${APP1} - replace_texts"

   for i in $SRC_FILES
   do
     i="*.$i*"
     for j in `find . -name $i -type f`
     do
	#bunch of replace patterns for various strings
        #in links for various apps

	regsub $j $CGI_BIN_TEXT_REP $CGI_BIN_TEXT_SUB
	regsub $j $URL_HOME_PAT  $URL_PROD_PAT
	regsub $j "$REP_LIB_PAT1"  "$PROD_SUB_LIB"
	regsub $j "$REP_REQ_PAT2"  "$PROD_SUB_REQ"
	regsub $j $GEN_RSRC_PAT  $PROD_GEN_RSRC_PAT
	regsub $j $ONEOFF1_PAT  $ONEOFF1_REP_PAT
	regsub $j $ONEOFF2_PAT  $ONEOFF2_REP_PAT

     done
   done

}

##########
#function#
##########
backup_app()
{
   display "${APP1} - backup_app"

   $MV $PROD_ROOT_PATH/${APP1} $PROD_ROOT_PATH/${APP1}_`date '+%m.%d.%Y:%H:%M:%S'`
   $MV $PROD_CGI_BIN/${APP1} $PROD_CGI_BIN/${APP1}_`date '+%m.%d.%Y:%H:%M:%S'`

}

##########
#function#
##########
deploy_app()
{
   display "${APP1} - deploy_app"

   [ -d $PROD_ROOT_PATH/${APP1} ] || $MKDIR $PROD_ROOT_PATH/${APP1} || error 12;
   [ -d $PROD_CGI_BIN/${APP1} ] || $MKDIR $PROD_CGI_BIN/${APP1} || error 12;

   [ $APP1 = "dcoda.net" ] && ( $CP index.html $PROD_ROOT_PATH/${APP1}/ || warn 12 )
   
   [ $APP1 = "pollCenter" ] && ( display "one off for ${APP1}" ) &&  
	( regsub 'cgi-bin/config.pl' $REP_POLLSESSIONS_DIR $PROD_SUB_POLLSESSIONS_DIR )

   echo $PWD   

   ( $CP -R web_src/ $PROD_ROOT_PATH/${APP1}/ ||  $CP -R js/ $PROD_ROOT_PATH/${APP1}/ || warn 11 ) &&
   ( $CP -R script_src/ $PROD_ROOT_PATH/${APP1}/ || warn 11 ) &&
   ( $CP -R gen_rsrc/ $PROD_ROOT_PATH/${APP1}/ || warn 11 ) &&
   ( $CP -R cgi-bin/ $PROD_CGI_BIN/${APP1}/  || warn 11 ) &&
   ( $CP *  $PROD_ROOT_PATH/${APP1}/ 2> /dev/null ) 

   ##################
   # temporary code #
   ##################

   [ $APP1 = "compSciCentral" ] && ( display "one off for ${APP1}" ) &&  ( $CP *  $PROD_ROOT_PATH/${APP1}/ )
   [ $APP1 = "chatterBox" ] && ( display "one off for ${APP1}" ) &&  ( $LINK web_src/chatterbox.html index.htm )
   [ $APP1 = "stockApp" ] && ( display "one off for ${APP1}" ) &&  ( $LINK web_src/index.htm . )
   [ $APP1 = "pollCenter" ] && ( display "one off for ${APP1}" ) && 
	( $MKDIR $PROD_ROOT_PATH/${APP1}/sessions || warn 11 ) && 
		( $CHMOD 777 $PROD_ROOT_PATH/${APP1}/sessions  || warn 11 ) 
   
}

######
#main#
######
[ ! -z $APP1 ] && ( [ $APP1 = "help" ] )  && usage

case $2 in
	  "pack") 	pack_app;;
	"unpack")      	unpack_app
			replace_texts
			backup_app
			deploy_app;;
	"deploy")	deploy_app;;
esac


