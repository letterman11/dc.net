#!/bin/bash
#set -x

#--------------------------------------------------------------------
# script: deploy_current
# author: ubuntu brooks
# purpose: deploy classic and new apps to dcoda.net website
#--------------------------------------------------------------------

export HOME=/home/ubuntu
#export HOME=/home/ubuntu
#export git_master=$HOME/lmate_master
export git_master=$HOME/fed_master
export classic_apps_git_url=https://github.com/letterman11/perlApps
export main_lib_git_url=https://github.com/letterman11/dc.net

export dcoda_net_apache_cfg=dcoda_net_site.dev.conf
export apache_config_dir=/etc/apache2/sites-available


export main_home=$HOME/dcoda_net
export demo_home=$HOME/demo_dcoda_net
export games_home=$HOME/games_dcoda_net

export marksBeta=marksPWA
export marksDelta=marksPWAPage

export mysql_client=mysql-client-core-8.0 

export data_server=cloud_server.cloud.one

export port=3306
export user=dococt

declare -a CLASSIC_APPS=("stockApp" "webMarks" "chatterBox" "pollCenter")

declare -a SRCs=(".js" ".pl" ".pm" ".htm" ".html" ".cgi" ".css")

export LINK="ln -s"
export INSTALL_Y="apt install -y"
#export INSTALL_Y="dnf install -y"


function update_os_package()
{
        sudo apt update
}

function grant_world_exec()
{
	sudo chmod 0755 $HOME
}


#--install git
function install_git()
{
	sudo $INSTALL_Y git
}

#--install apache2
function install_apache2()
{
	sudo $INSTALL_Y apache2
}

#--- install mysql client libs
function install_mysql_client()
{
	sudo $INSTALL_Y $mysql_client 
	sudo apt-get install -y libmysqlclient-dev
}

function create_git_master_dir()
{
	mkdir $git_master
}

function clone_git_repos()
{
	cd $git_master
	git clone $classic_apps_git_url
	git clone $main_lib_git_url

	#--- one off rename for stockApp
	mv $git_master/perlApps/StockApp $git_master/perlApps/stockApp

}

function setup_session_db()
{
	ln -s $main_home/lib/sessionFile.dat $main_home/cgi-bin/stockApp/cgi-bin/sessionFile.dat
	ln -s $main_home/db/dcoda_acme.webMarks $main_home/db/sessionDB

	#sed -i 's#ubuntu#ubuntu#g' $main_home/lib/sessionFile.dat
	#sed -i 's#ubuntu#ubuntu#g' $main_home/lib/sessionFile.dat
	sed -i 's#plack_home#dcoda_net#g' $main_home/lib/sessionFile.dat

}


function create_main_app_dirs()
{
	mkdir $main_home
	mkdir $demo_home
	mkdir $games_home


	mkdir $main_home/logs
	mkdir $demo_home/logs
	mkdir $games_home/logs


}

function apache2_setup()
{
	sudo a2enmod proxy
	sudo a2enmod proxy_http
	sudo a2enmod proxy_balancer
	sudo a2enmod lbmethod_byrequests
	sudo a2enmod cgi
	sudo a2enmod ssl
	install_webserver_configs

}

function install_webserver_configs()
{
	sudo cp $git_master/dc.net/conf/$dcoda_net_apache_cfg $apache_config_dir
	cd $apache_config_dir
	regsub $dcoda_net_apache_cfg angus ubuntu
#	regsub $dcoda_net_apache_cfg locahost pub_ip 

	#must enable ec2 metadata v1 for simple command below otherwise
	#complex v2 cmd required
	pub_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
	sed -i 's#ServerName localhost#ServerName '$pub_ip'#g' $dcoda_net_apache_cfg
 	#regsub $dcoda_net_apache_cfg locahost $pub_ip 

	cat <<mesg
######################
######## $PWD
######## ls $apache_config_dir
########  $pub_ip
#####################
mesg

#	mv $dcoda_net_apache_cfg $dcoda_net_apache_cfg.conf

	sudo a2ensite $dcoda_net_apache_cfg

	sudo systemctl reload apache2
}

function create_main_sub_dirs()
{
	mkdir $main_home/cgi-bin
	mkdir $main_home/private
	mkdir $main_home/db
	mkdir $main_home/public
	mkdir $main_home/public
	mkdir $main_home/public/gen_rsrc
	mkdir $main_home/public/static
#	mkdir $main_home/public/static/
	mkdir $main_home/lib

	chmod -R 0777 $main_home/db
	chmod -R 0777 $main_home/lib

}

function create_demo_sub_dirs()
{
	mkdir $demo_home/public
	mkdir $demo_home/public/gen_rsrc
	mkdir $demo_home/public/static
	mkdir $demo_home/public/images
	mkdir $demo_home/public/js
	mkdir $demo_home/public/css

}

#-- perl prereqs download & installs
function install_cgi_mods()
{
	sudo $INSTALL_Y cpanminus
	sudo cpanm CGI
	sudo cpanm CGI::Cookie
	sudo cpanm DBI
	sudo cpanm DBD::SQLite
	sudo cpanm DBD::mysql
	sudo cpanm DateTime
}




function deploy_stock_sqlite()
{
	cp $git_master/perlApps/stockApp/data/dcoda_acme.gz $main_home/db/dcoda_acme.gz
	gunzip -y $main_home/db/dcoda_acme.gz

}

function install_classic_apps_to_main()
{
	#--- cgi-bins
	for app in ${CLASSIC_APPS[@]}
		do
			mkdir $main_home/cgi-bin/$app
			cp -r $git_master/perlApps/$app/cgi-bin $main_home/cgi-bin/$app/

			[[ $app == "stockApp" ]] && ( $LINK $main_home/lib/sessionFile.dat $main_home/cgi-bin/$app/cgi-bin/sessionFile.dat ) 
			[[ $app == "stockApp" ]] && ( deploy_stock_sqlite )
			[[ $app == "webMarks" ]] && ( mv $main_home/cgi-bin/$app/cgi-bin/wm_app.cgi $main_home/cgi-bin/$app/cgi-bin/wm_app.cgi.old ) && 
										( $LINK $main_home/cgi-bin/$app/cgi-bin/wm_app_improved.cgi $main_home/cgi-bin/$app/cgi-bin/wm_app.cgi ) &&
										( cp $HOME/dcoda_acme.webMarks $main_home/db/ ) 
			copy_db_file $app 

		done

	#--- private modules
	for app in ${CLASSIC_APPS[@]}
		do
			mkdir $main_home/private/$app
			cp -r $git_master/perlApps/$app/script_src $main_home/private/$app/

		done

	#--- data modules
	for app in ${CLASSIC_APPS[@]}
		do
			mkdir $main_home/private/$app
			cp -r $git_master/perlApps/$app/data $main_home/private/$app/

		done

	#--- public files
	for app in ${CLASSIC_APPS[@]}
		do
			mkdir $main_home/public/$app
			cp -r $git_master/perlApps/$app/web_src $main_home/public/$app/
			cd $main_home/public/$app

			[[ $app == "chatterBox" ]] && ( $LINK $main_home/public/$app/web_src/chatterbox.html index.htm ) 

			[[ $app == "pollCenter" ]] && ( cp -R $git_master/perlApps/$app/skins $main_home/public/$app/ ) && 
							( cp -R $git_master/perlApps/$app/js $main_home/public/$app/ ) && 
							( cp $git_master/perlApps/$app/*.css $main_home/public/$app/ ) &&
							( cp $git_master/perlApps/$app/index.htm* $main_home/public/$app/ ) 

			$LINK $main_home/public/$app/web_src/index.htm . 

		done


	#--- public image files
	for app in ${CLASSIC_APPS[@]}
		do
			mkdir $main_home/public/$app/images
			cp $git_master/perlApps/$app/gen_rsrc/* $main_home/public/$app/images/
			cp $git_master/perlApps/$app/gen_rsrc/* $main_home/public/$app/gen_rsrc/
			cp $main_home/public/$app/images/* $main_home/public/images/
		done

	#--- public gen_rsrc files
	for app in ${CLASSIC_APPS[@]}
	do
		mkdir $main_home/public/$app
		cp -r $git_master/perlApps/$app/gen_rsrc $main_home/public/$app/

	done

	chmod -R 0755 $main_home

}

function install_new_site_apps()
{
	install_py_webMarks
	install_py_webMarks_beta
	install_py_webMarks_delta
	install_py_webMarks_gamma
	install_expressChat

}

function install_py_webMarks()
{
	cd $git_master

	git clone https://github.com/letterman11/pyUp
	ln -s $git_master/pyUp $HOME/.

	cp $HOME/pyUp/py3x/bottleMarks/public/images/*	$demo_home/public/static/images/	

	ln -s $HOME/pyUp/py3x/bottleMarks/public/css	$demo_home/public/static/css
	ln -s $HOME/pyUp/py3x/bottleMarks/public/js		$demo_home/public/static/js

	copy_db_file bottleMarks $HOME/pyUp/py3x/bottleMarks
}


function install_py_webMarks_beta()
{
	cd $git_master
	mkdir $demo_home/public/static/ex


	cd pyUp/py3x
	git worktree add --track -b marksPWA marksPWA origin/marksPWA

	cp $HOME/pyUp/py3x/$marksBeta/py3x/bottleMarks/public/images/*	$demo_home/public/static/images/	

	ln -s $HOME/pyUp/py3x/$marksBeta/py3x/bottleMarks/public/css	$demo_home/public/static/ex/.
	ln -s $HOME/pyUp/py3x/$marksBeta/py3x/bottleMarks/public/js		$demo_home/public/static/ex/.

	copy_db_file $marksBeta $HOME/pyUp/py3x/$marksBeta/py3x/bottleMarks

}

function install_py_webMarks_delta()
{
	cd $git_master
	mkdir $demo_home/public/static/ex2

	cd pyUp/py3x
	git worktree add --track  -b marksPWAPage  marksPWAPage origin/marksPWAPage

	cp $HOME/pyUp/py3x/$marksDelta/py3x/bottleMarks/public/images/*	$demo_home/public/static/images/	

	ln -s $HOME/pyUp/py3x/$marksDelta/py3x/bottleMarks/public/css	$demo_home/public/static/ex2/.
	ln -s $HOME/pyUp/py3x/$marksDelta/py3x/bottleMarks/public/js		$demo_home/public/static/ex2/.

	copy_db_file $marksDelta $HOME/pyUp/py3x/$marksDelta/py3x/bottleMarks

}

function install_expressChat()
{
	cd $git_master

	git clone https://github.com/letterman11/joule
	mkdir $demo_home/public/static/
	
	ln -s $git_master/joule/chatBoxExpress $HOME/.

	cp $HOME/chatBoxExpress/public/images/*			$demo_home/public/static/images/	

	ln -s $HOME/chatBoxExpress/public/stylesheets	$demo_home/public/static/.
	ln -s $HOME/chatBoxExpress/public/javascripts	$demo_home/public/static/.

	copy_db_file $expressChat $HOME/chatBoxExpress

}

function install_mojoMarks()
{
	cd $git_master

	git clone https://github.com/letterman11/perlMojo
	mkdir $demo_home/public/static/mojo
	
	ln -s $git_master/perlMojo $HOME/.

	cp $HOME/perlMojo/MojoWebMarks/public/images/*	$demo_home/public/static/images/	

	ln -s $HOME/perlMojo/MojoWebMarks/public/css	$demo_home/public/static/mojo/.
	ln -s $HOME/perlMojo/MojoWebMarks/public/js	$demo_home/public/static/mojo/.

	copy_db_file $mojoMarks $HOME/perlMojo/MojoWebMarks
}

#--- exec data sqls for each app
function populate_apps_schema()
{
for app in ${CLASSIC_APPS[@]}
do
	cd $main_home/private/$app/data		

	for exec_data in `ls *.sql`
	do
		mysql -u $user -p -h $data_server --port $port < $exec_data

	done
done
		
}

function one_offs()
{
	cd $git_master
	cd dc.net
	cp lib/sessionFile.dat $main_home/lib

	cp $git_master/dc.net/public/index.htm $main_home/public/
	cp $git_master/dc.net/public/index.htm $main_home/public/

	cp -R $git_master/dc.net/public/css $main_home/public/css
	cp -R $git_master/dc.net/public/js $main_home/public/js
	cp -R $git_master/dc.net/public/images $main_home/public/images

	ln -s $main_home/public/images $main_home/public/static/images

	chown -R ubuntu:ubuntu $main_home
	chown -R ubuntu:ubuntu $demo_home
	chown -R ubuntu:ubuntu $games_home

}

function one_offs_two()
{
    create_demo_sub_dirs

	cd $git_master
	cd dc.net

	cp $git_master/dc.net/demo_dcoda_net/public/index.htm* $demo_home/public/
	cp $git_master/dc.net/demo_dcoda_net/public/css/* $demo_home/public/css
	cp $git_master/dc.net/demo_dcoda_net/public/js/* $demo_home/public/js
	cp $git_master/dc.net/demo_dcoda_net/public/images/* $demo_home/public/images

	cp $git_master/dc.net/public/images/* $demo_home/public/images

	ln -s $demo_home/public/images $demo_home/public/static/images

	cp $git_master/pyUp/py3x/bottleMarks/public/images/* $demo_home/public/images/
	cp $git_master/pyUp/py3x/marksPWA/py3x/bottleMarks/public/images/* $demo_home/public/images/

	cp $git_master/perlMojo/MojoWebMarks/public/images/* $demo_home/public/images/
	cp $git_master/joule/chatBoxExpress/public/images/* $demo_home/public/images/

	


	setup_session_db

	#ln -s $main_home/lib/sessionFile.dat $main_home/cgi-bin/stockApp/cgi-bin/sessionFile.dat
	#ln -s $main_home/db/dcoda_acme.webMarks $main_home/db/sessionDB

	chmod -R 777 $main_home/db

	chown -R ubuntu:ubuntu $HOME/*
}

function copy_db_file()
{
	app=$1
    path=$2

#	cp $HOME/bin/stockDbConfig.dat $main_home/cgi-bin/$app/cgi-bin/.
	cp $HOME/stockDbConfig.dat $main_home/cgi-bin/$app/cgi-bin/.

	if [[ $# > 1 ]];then

		cp $HOME/stockDbConfig.dat $

	else
		cp $HOME/stockDbConfig.dat $path/.

	fi

}

function replace_user()
{
	old_user=$1
	new_user=$2

	cd $main_home
	for src_file in ${SRCs[@]}
	do
		for file in `find . -iname *$src_file -type f`
		do
			#sed -i 's#$old_user#$new_user#' $i
			regsub $file $old_user $new_user
		done
	done
}

function regsub()
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


function install_infrastructure()
{	
	install_git
	install_apache2
	install_mysql_client
}

function main()
{
	grant_world_exec
	update_os_package
	install_git					#--1
	install_mysql_client				#--2
	create_git_master_dir				#--3

	clone_git_repos					#--4
	install_new_site_apps				#--4a
	
	create_main_app_dirs				#--5
	create_main_sub_dirs				#--6
	install_classic_apps_to_main			#--7
#	populate_apps_schema				#--8
	install_cgi_mods				#--9
	install_apache2					#--10
	apache2_setup					#--11

	one_offs
	one_offs_two
	replace_user ubuntu ubuntu

}


function usage()
{

cat<<mesg

deploy_current.sh [-u | -p ] 
                  -u <user> user logged in
                  -p <port> database port
                  -e populate all app database scripts


mesg
}



while getopts "aeu:p:" opt; do
	no_args=0
    case $opt in
       u) new_user=$OPTARG;;
       p) port=$OPTARG;;
	   e) populate_apps_schema;; 
	   ?) usage;;
    esac
done

if [[ !  $no_args ]];then
	main
fi


