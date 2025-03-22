#!/usr/bin/perl 
use strict;
use feature 'say';
use Tie::IxHash;
use Getopt::Long;


#my $write_db_file = "config.dat.go";
my $write_db_file = "stockDbConfig.dat";
my $default_path =  $ENV{HOME} . "/dcoda_net/cgi-bin/stockApp";
my $default_config = "$ENV{HOME}/bin/" . "stockDbConfig.cfg";
my $test_sec = "SQLITE";
my ($config_file,$app_file,$app_sel,$app,$db_sel);
my $DEBUG = 0;

GetOptions("config-file=s" => \$config_file,
			"app-file=s" => \$app_file,
			"db-sel=s" => \$db_sel,
			"app-sel=s" => \$app_sel,
			"app=s" => \$app,
			 "debug" => \$DEBUG);

my %serv_config = ( "ALL" => ["STOCKAPP", "WEBMARKS", "CHATBOX", "POLLCENTER", "WEBMARKS_PY", "WEBMARKS_BETA", "WEBMARKS_DELTA", "EXPRESSCHAT"],
			  "CLASSIC" => ["STOCKAPP", "WEBMARKS", "CHATBOX", "POLLCENTER"],
			  "NEW" => ["WEBMARKS_PY", "WEBMARKS_BETA", "WEBMARKS_DELTA", "EXPRESSCHAT"],
			  "APP" => [$app],
			);

#[STOCKAPP] [WEBMARKS] [CHATBOX] [POLLCENTER] [WEBMARKS_PY] [WEBMARKS_BETA] [WEBMARKS_DELTA] [EXPRESSCHAT]

$config_file = $ARGV[0] || $default_config;
my $path = $ARGV[1] || $default_path;

$path = undef;


tie my %db_serv_cfg, "Tie::IxHash";


say $ENV{HOME} if $DEBUG;

read_config();


$app_sel = ($app_sel =~ /SOME/i) ? "APP" : $app_sel;

for my $app (@{$serv_config{uc $app_sel}})
{
    my $path = read_config($app_file, $app);
    say $write_db_file, " #---------------------#" if $DEBUG;
    write_config("$path/$write_db_file",$db_sel);
    if ($app =~ /stockapp/i ) {
	 #one off for stockApp
	 `sed -i "s#dcoda_acme.webMarks#dcoda_acme.stockApp#g" $path/$write_db_file`;

    }
}


#--------------------------------------------
#
#--------------------------------------------
sub read_config
{

   my $config_file  =  defined($_[0]) ?  $_[0] : $default_config; 
   my $sect         =  defined($_[1]) ?  $_[1] : ""; 

   my $curr_sec;
   my $path_out;
   my $flag;

   open(FH, "<$config_file") or die "Cannot open config-file: $config_file\n";
   while(<FH>)
   {
     next if /^#+/;
     next if /^\s*$/;
     if (/\[([A-Za-z0-9\s\_]+)\]/)
     {
       $curr_sec = $1;
	   say $1 if $DEBUG;
	   #
	   #
	   #control flow for app_config
      next if defined($_[0]);

      $db_serv_cfg{uc($curr_sec)} = {};

      tie ( %{ $db_serv_cfg{uc($curr_sec)} }, "Tie::IxHash"); 

     }
     elsif (/=/)
     {
       my ($key,$value)= split /=/;
       $key =~ s/\s*//;
       $value =~ s/\s*\t*\n//;

       chomp($key,$value);

	   #control flow for app_config
    
       if (defined($_[0]) && $sect =~ /$curr_sec/i  )
       {
          $path_out = $value;
          next; 
       }
       elsif(defined($_[0]))
       {
	      next;
       }
       $db_serv_cfg{uc($curr_sec)}->{$key}=$value;

       }
   }
   close(FH);
   return $path_out;
}


#-------------------------------------------
#
#-------------------------------------------
sub write_config
{

   my $write_file = shift || $write_db_file;
   my $db_sec = shift || $test_sec;

   open(FH, ">$write_file") or die "Cannot open write_file: $write_file\n";

   say FH<<here;
#-----------------------------------
#  DATABASE CONFIG  FILE
#-----------------------------------

here
    for my $k (keys %db_serv_cfg)
    {
    	say FH;
    	say FH comm_out($k,$db_sec), "[$k]";
    	say FH comm_out($k,$db_sec), "----------------------";
	    say FH;
	    while (my ($key, $value) = each %{$db_serv_cfg{$k}}) 
    	{
	        say FH comm_out($k,$db_sec), $key, "=",  $value;
    	} 
    }
} 

 
#--------------------------------------------
#
#--------------------------------------------
sub comm_out
{
    my $k = $_[0];
    my $test_sec = $_[1];

    return  ($k =~ /$test_sec/i) ? "" : "#"; 
}





