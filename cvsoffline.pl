#!perl
#----------------------------------------------------------------------
=pod                                                                                                                                                   

=head1  NAME                                                                                                                                           

~/cvsoffline.pl                                                                                                                            

=head1  USAGE                                                                                                                                          

perl ~/cvsoffline.pl /usr/local/cvsroot platform/eir-epage-cronjobs /CVSROOT/cvs.arcvhive

=head1  DESCRIPTION

This script will take a given build offline under the assumption that it
has migrated to git.

The specified directory will be packaged and placed in $3/`basename $2`.tar.gz                                                                                     

=head1 PARAMETERS                                                                                                                                      

/usr/local/cvsroot          - explicit path from the denuded migrate.sh
platform/eir-epage-cronjobs - Assumed to be found under $ARGV[1].
/CVSROOT/cvs.archive        - Where we put the tarball

=cut                                                                                                                                                   

use Data::Dumper;

main( @ARGV );
exit( 0 );



#----------------------------------------------------------------------                                                                                
sub     main
{
    my( $cvsroot )      = shift;
    my( $build )        = shift;
    my( $archive )      = shift;
    if  ($build =~ /\//)                        ## MUST have at least 1 slash (/).                                                                     
    {
        if  (-d "$cvsroot/$build")
        {
            my( $basename )     = `basename $build`;
            chomp( $basename );
            my( $tarball )      = "$archive/$basename.tar.gz";
            unless( -f $tarball )
            {
                chdir( "$cvsroot" );
                my( $tar )      = "tar cvzf $tarball $build";
                print `$tar`;
                my( $size )     = -s $tarball;
                if  ($size > 1024)
                {
                    print `ls -l $tarball`;
                    print "rm -rf $cvsroot/$build\n";
                    print `rm -rf $cvsroot/$build`;
                }
            }
            else
            {
                print "ERROR: Unwilling to clober existing $tarball!  Hand-touch required to disambiguate.\n";
            }
        }
        else
        {
            print "ERROR: $cvsroot/$build does not exist as a directory.\n";
        }
    }
    else
    {
        print "ERROR: $build MUST have at least one slash in order to migrate.\n";
    }
}
