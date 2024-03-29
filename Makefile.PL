## --Makefile.PL for Bioperl core module distribution--##
## ----------------------------------------------------##
## $Id: Makefile.PL,v 1.4 2003/09/17 09:51:20 allenday Exp $
##----------------------------------------------------

#
# Basically this is a standard Makefile with a hash of
# needed packages which are tested at the start
#
# If you want help with this Makefile get in touch with
# the developers by sending a message to bioperl-l@bioperl.org.



# All Bioperl dependencies on external modules are defined here
%packages = (
	     'Class::MakeMethods::Emulator' => '1.008/Autogeneration of Methods/Saves wear on the wrists & fingers/Bio::Expression::Microarray*',
	     'enum'                         => '0.0/C style enumerated types and bitmask flags in Perl/Bio::Microarray::Affymetrix::*',
	     );

sub check_package {
    my ($name,$str) = @_;
    my ($ver,$desc,$expl,$module) = split( /\// , $str);
    if( !eval "require($name)") {
	print "External Module $name, $desc,\n is not installed on this computer.\n  The $module in Bioperl needs it for $expl\n\n";
	return 1;
    }

    return 0;
}

#
# Generate sub testing package system
#
#

# make mini test targets for playing around with
# in testing...

opendir(DIR,"t") || warn "No test directory. Weird!";
@files = readdir(DIR);
shift @files;
shift @files;
foreach my $file (@files) {
    $file =~ /(\w+)\.t/ || next;
    $file = $1;
    $line = "test_$file :: pure_all\n\tPERL_DL_NONLAZY=1 \$(FULLPERL) -I\$(INST_ARCHLIB) -I\$(INST_LIB) -I\$(PERL_ARCHLIB) -I\$(PERL_LIB) -e \'use Test::Harness qw(&runtests \$\$verbose); \$\$verbose=\$(TEST_VERBOSE); runtests \@ARGV;\' t/$file.t\n";
    push(@tline,$line);
    push(@targets,$file);
    $tset  .= "$file \\\n";
}

$tline = join('',@tline);
$tline = "show_tests :\n\t\@echo \'type make test_<subtest> to run\'\n\t\@echo '$tset'\n$tline\n";

print STDERR "Generated sub tests. go make show_tests to see available subtests\n";

sub MY::postamble {
             $tline;
           }

# Let the code begin...

require 5.005;
use ExtUtils::MakeMaker ;

$do_autoload_finesse = 0;
$NAME     = 'Bio';
$DISTNAME = "bioperl-microarray";
$VERSION  = "0.1";

$error = 0;
print "\n";
foreach $name ( keys %packages ) {
    if( &check_package($name,$packages{$name}) == 1 ) {
	$error = 1;
    }
}

if( $error == 1 ) {
    print <<QQ_ERROR_QQ;

Warning:

   There are some external packages and perl modules, listed above, which 
   bioperl uses. This only effects the functionality which is listed above:
   the rest of bioperl will work fine.

   The installation of these external packages is very simple. You
   can read more about bioperl external dependencies at

   http://bioperl.org/Core/external.shtml

   Enjoy the rest of bioperl, which you can use after going 'make install'

QQ_ERROR_QQ
}

WriteMakefile(
    NAME	=> $NAME,
    DISTNAME    => $DISTNAME,
    VERSION     => $VERSION,
    'dist'      => {  COMPRESS     => 'gzip -9f',
                      SUFFIX       => '.gz', 
                      DIST_DEFAULT => 'all tardist',
                   },
    ($] ge '5.005')  ? (
     'AUTHOR'   => 'Bioperl Team (bioperl-l@bioperl.org)',
     'ABSTRACT' => 'Bioperl Toolkit - Addendum for microarray data',
    ) : (),
    'realclean' => {  FILES        => join(' ',@BACKUP_FILES) },
    DIR         => [  ], # directories with other Makefile.PL's in them
);
