use lib "$ENV{HOME}/dcoda_net/lib";
use Plack::Builder;
use Plack::App::File;
use Plack::App::CGIBin;


my $app1 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public")->to_app;
my $app0 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/stockApp")->to_app;
my $app2 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/chatterBox")->to_app;
my $app3 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/pollCenter")->to_app;
my $app4 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/businessCentral")->to_app;
my $app5 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/compSciCentral")->to_app;
my $app6 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/webMarks")->to_app;
my $app7 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/autoCentral")->to_app;
my $app8 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/boatCentral")->to_app;
my $app9 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/threadCentral")->to_app;
my $app10 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/circuitCentral")->to_app;
my $app11 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/bookCentral")->to_app;
my $app_base = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/dcoda.net")->to_app;
#my $app6 = Plack::App::File->new(root => "$ENV{HOME}/dcoda_net/public/webMarks")->to_app;


# CGI bin for applications
# #########################
#my $app_cgibin_stockApp = Plack::App::CGIBin->new(root => "/cgi-bin/stockApp/cgi-bin")->to_app;
my $app_cgibin_stockApp = Plack::App::CGIBin->new(
      root => "$ENV{HOME}/dcoda_net/cgi-bin/stockApp/cgi-bin",
      exec_cb => sub { 1 },
  )->to_app;

my $app_cgibin_chatterBox = Plack::App::CGIBin->new(
      root => "$ENV{HOME}/dcoda_net/cgi-bin/chatterBox/cgi-bin",
      exec_cb => sub { 1 },
  )->to_app;
#my $app_cgibin_chatterBox = Plack::App::CGIBin->new(root => "/cgi-bin/chatterBox/cgi-bin")->to_app;

my $app_cgibin_pollCenter = Plack::App::CGIBin->new(
      root => "$ENV{HOME}/dcoda_net/cgi-bin/pollCenter/cgi-bin",
      exec_cb => sub { 1 },
  )->to_app;

my $app_cgibin_webMarks = Plack::App::CGIBin->new(
      root => "$ENV{HOME}/dcoda_net/cgi-bin/webMarks/cgi-bin",
      exec_cb => sub { 1 },
  )->to_app;

# End Cgi bin for applications
##########################

#######################################
##### MAIN START OF BUILDER   #########
#######################################

my $app = builder {

   ##########  Mount CGIBINS  ########################

   mount "/cgi-bin/stockApp/cgi-bin" => builder {
      $app_cgibin_stockApp;
  };

   mount "/cgi-bin/chatterBox/cgi-bin" => builder {
      $app_cgibin_chatterBox;
  };

   mount "/cgi-bin/pollCenter/cgi-bin" => builder {
      $app_cgibin_pollCenter;
  };

   mount "/cgi-bin/webMarks/cgi-bin" => builder {
      $app_cgibin_webMarks;
  };

   ######## END Mount CGIBINS ##########################

  #** Monitoring Application  ****

   mount "/ConAppTest" =>  builder {
        enable 'Deflater';
        require '../MojoPro/MonApp';
  };

  #** End Monitoring Application Section ***

    mount "/" => builder {
      #enable "Debug";
      enable "Plack::Middleware::Static",
      path => sub { s(^/$)(/index.htm) }, root => "$ENV{HOME}/dcoda_net/public";
      $app1;
   };
    mount "/dcoda.net" => builder {
#      enable "Debug";
      enable "Plack::Middleware::Static",
      path => sub { s(^$)(/index.htm) }, root => "$ENV{HOME}/dcoda_net/public";
      $app_base;
   };
    mount "/stockApp" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.htm) }, root => "$ENV{HOME}/dcoda_net/public/stockApp";
      enable "Plack::Middleware::VisitLogger";
      $app0;
   };

   mount "/chatterBox" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/chatterBox";
      enable "Plack::Middleware::VisitLogger";
      $app2;
  };

   mount "/pollCenter" => builder {
      #enable "Debug";
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.htm) }, root => "$ENV{HOME}/dcoda_net/public/pollCenter";
      enable "Plack::Middleware::VisitLogger";
      $app3;
  };
   mount "/businessCentral" => builder {
#      enable "Debug";
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/businessCentral";
      enable "Plack::Middleware::VisitLogger";
      $app4;
  };
   mount "/compSciCentral" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/compSciCentral";
#      enable "Debug";
      enable "Plack::Middleware::VisitLogger";
      $app5;
  };

   mount "/autoCentral" => builder {
#      enable "Plack::Middleware::VisitLogger";
      enable "Debug";
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(/index.html) }, root => "$ENV{HOME}/dcoda_net/public/autoCentral";
      $app7;
  };

   mount "/boatCentral" => builder {
#      enable "Plack::Middleware::VisitLogger";
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/boatCentral";
      $app8;
  };

   mount "/threadCentral" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/threadCentral";
      enable "Plack::Middleware::VisitLogger";
      $app9;
  };

   mount "/circuitCentral" => builder {
      enable "Debug";
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/circuitCentral";
      enable "Plack::Middleware::VisitLogger";
      $app10;
  };

   mount "/bookCentral" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.html) }, root => "$ENV{HOME}/dcoda_net/public/bookCentral";
      enable "Plack::Middleware::VisitLogger";
      $app11;
  };


   mount "/webMarks" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index.htm) }, root => "$ENV{HOME}/dcoda_net/public/webMarks";
      enable "Plack::Middleware::VisitLogger";
      $app6;
  };

   mount "/webMarks_mb" => builder {
      enable "Plack::Middleware::Static",
      path => sub { s(^$|^/$)(index_mb.htm) }, root => "$ENV{HOME}/dcoda_net/public/webMarks";
      enable "Plack::Middleware::VisitLogger";
      $app6;
   };


};

#my $urlmap = Plack::App::URLMap->new;
#$ENV{HOME}/dcoda_net/public/chatterBox
#my $urlmap = Plack::App::URLMap->new;
#$urlmap->map("/ConApp" => $capp);
#$urlmap->map("/chatterBox" => $app2);
#$urlmap->map("/pollCenter" => $app3);
#$urlmap->map("/compSciCentral" => $app4);
#$urlmap->map("/businessCentral" => $app5);

      #path => sub { s(^$)(/index.htm) }, root => "$ENV{HOME}/dcoda_net/public/stockApp";

#my $app = $urlmap->to_app;

