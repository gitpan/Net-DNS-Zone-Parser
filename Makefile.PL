use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Net::DNS::Zone::Parser',
    'VERSION_FROM' => 'Parser.pm', # finds $VERSION
    'AUTHOR'  => 'Olaf M. Kolkman (RIPE NCC)',
    'dist'         => { COMPRESS => 'gzip', SUFFIX => 'gz' },
    'ABSTRACT'     => 'Perl DNS Zone module',
    'PREREQ_PM'    => {
		       Net::DNS       => 0.46,
		       Net::DNS::SEC  => 0.11,
		       IO::File   =>  0.0,
		       File::Basename => 0.0,
			},
    'PM' => { 
	'Parser.pm'    => '$(INST_LIBDIR)/Parser.pm',
    },




);
