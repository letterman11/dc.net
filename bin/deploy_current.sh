#!/bin/bash
set -x

export git_master=$HOME/lmate_master
export classic_apps_git=https://github.com/letterman11/perlApps

export main_home=$HOME/dcoda_net
export demo_home=$HOME/demo_dcoda_net
export games_home=$HOME/games_dcoda_net

export mysql_client=mysql-client-core-8.0 

export data_server=cloud_server.cloud.one
export port=3306
export user=dococt

declare -a CLASSIC_APPS=("stockApp" "webMarks" "chatterBox" "pollCenter")


function install_git()
{
	sudo apt install -y git
}

function install_apache()
{
	sudo apt install -y apache2
}

function install_mysql_client()
{
	sudo apt install -y $mysql_client 
}

function create_git_master_dir()
{
	mkdir $git_master
}

function clone_git_repos()
{
	cd $git_master
	git clone $class_apps_git

	#--- one off rename for stockApp
	mv $classic_apps_git/StockApp $classic_apps_git/stockApp

}

function create_main_app_dirs()
{
	mkdir $main_home
	mkdir $demo_home
	mkdir $games_home

}

function apache2_setup()
{
	sudo a2enmod proxy
	sudo a2enmod proxy_http
	sudo a2enmod proxy_balancer
	sudo a2enmod lbmethod_byrequests
	sudo a2enmod cgi
	sudo a2enmod ssl

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
	mkdir $main_home/public/static/images
	mkdir $main_home/lib

	chmod -R 0777 $main_home/db
	chmod -R 0777 $main_home/lib

}


#-- perl prereqs download & installs
function install_cgi_mods()
{
	sudo apt install -y cpanminus
	sudo cpanm CGI
	sudo cpanm CGI::Cookie
	sudo cpanm DBI
	sudo cpanm DBD::SQLite
	sudo cpanm DBD::mysql
	sudo cpanm DateTime
}

function install_classic_apps_to_main()
{
#--- cgi-bins
for app in ${CLASSIC_APPS[@]}
	do
		cp -R $git_master/perlApps/$app/cgi-bin $main_home/cgi-bin/$app/

	done

#--- private modules
for app in ${CLASSIC_APPS[@]}
	do
		cp -R $git_master/perlApps/$app/script_src $main_home/private/$app/

	done

#--- data modules
for app in ${CLASSIC_APPS[@]}
	do
		cp -R $git_master/perlApps/$app/data $main_home/private/$app/

	done

#--- public files
for app in ${CLASSIC_APPS[@]}
	do
		mkdir $main_home/public/$app
		cp -R $git_master/perlApps/$app/web_src $main_home/public/$app/

	done

#--- public gen_rsrc files
for app in ${CLASSIC_APPS[@]}
	do
		mkdir $main_home/public/$app
		cp -R $git_master/perlApps/$app/gen_rsrc $main_home/public/$app/

	done

chmod -R 0755 $main_home

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


function main()
{
	install_git							#--1
	install_mysql_client				#--2
	create_git_master_dir				#--3
	clone_git_repos						#--4
	create_main_app_dirs				#--5
	create_main_sub_dirs				#--6
	install_classic_apps_to_main		#--7
	populate_apps_schema				#--8
	install_cgi_mods					#--9
	install_apache2						#--10
	apache2_setup						#--11

}


cat<<comm
1a: create git master dir
1b: git clone repoistories

2a: mkdir 	dcoda_net
			demo_dcoda_net
			games_dcoda_net

2b: mkdir 	in dcoda_net dirs
		 	cgi-bin
			private
			public
			public/static

3:  cp over app specific (stockApp,webMarks,etc.) cgi-bins to main app dirs in 2a
3a: cp over app specific private modules to main app dirs in 2a
3b: cp over app specific public files to main app dirs in 2a

4:  set appropriate permissions in path to main app dirs

5:  cp over any sqlite databases to db dir of main app dir

comm
