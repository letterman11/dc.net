########################################
## test solo deploy of Mojo WebMarks ###
########################################
#
# Port 8087
#
use lib "/home/angus/dcoda_net/lib";
#use lib  "/home/angus/perlProjects/MojoWebMarks";
use Plack::Builder;
use Plack::App::File;
use Plack::App::CGIBin;

###########################################
# Cascading Document Roots for applications
#################################################################################
#my $app0 = Plack::App::File->new(root => "/home/angus/MojoWebMarks")->to_app;
#my $app6 = Plack::App::File->new(root => "/home/angus/dcoda_net/public/webMarks")->to_app;

# End of Document Roots for applications
###############################################################################################

# CGI bin for applications
# #########################

# End Cgi bin for applications
##########################

#######################################
##### MAIN START OF BUILDER   #########
#######################################

my $app = builder {

  #** Monitoring Application  ****
#   mount "/ConApp" =>  builder {
#        enable 'Deflater';
#        require '/home/angus/perlProjects/MojoWebMarks/MonAppG';
#  };

  #** End Monitoring Application Section ***

   mount "/" =>  builder {
        enable 'Deflater';
		enable 'Debug';
        require  '/home/angus/perlProjects/MojoWebMarks/MojoWebMarks';
  };


};


