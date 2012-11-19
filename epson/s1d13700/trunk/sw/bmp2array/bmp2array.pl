#!/c/Perl/bin/perl.exe
# =========================================================================
# Subversion Control:
# $Revision: 3 $
# $Date: 2011-06-24 10:14:14 +0800 (周五, 2011-06-24) $
# =========================================================================
# File     : bmp2array.pl
# Author   : Handsome Huang
# Abstract : Convert bmp file to C array.
# 
# =========================================================================
# Modification History:
# Date          By           Changes Description
# ---------------------------------------------------------------------
# 2012/09/20    Handsome     New creation
#
# =========================================================================
use Getopt::Std;

#----------------------------------------------------------------------
# Get parameters
#----------------------------------------------------------------------
getopts('b:');

#----------------------------------------------------------------------
# Parameters check
#----------------------------------------------------------------------
if (!(defined $opt_b))
{
    print "\n";
    print "Usage: $0 [option] <ret>\n";
    print "\n";
    print "  Option: Description\n";
    print "\n";                                
    print "    -b: Input bmp file name.\n";
    print "\n";
    print "Example:\n";
    print "$0 -b logo.bmp > output.h\n"; 
    print "\n";
    exit;
}

#----------------------------------------------------------------------
# Input/Output file name converting
#----------------------------------------------------------------------
# Get filename (remove extended .bmp)
$opt_b =~ s/.bmp$//;

# Generate input/output file name
$opt_b = $opt_b . ".bmp";          # input bmp file

#----------------------------------------------------------------------
# Reading input BMP file
#----------------------------------------------------------------------
open (IN_FILE, $opt_b) or die "can not open $opt_b\n";
binmode(IN_FILE);


#----------------------------------------------------------------------
# Reading BMP file header
#----------------------------------------------------------------------
%bmpFileHeader= (
    'bfType', 
    'bfsize', 
    'bfReserved', 
    'bfOffBits'
);

read(IN_FILE, $bmpFileHeader{'bfType'}, 2);
read(IN_FILE, $bmpFileHeader{'bfSize'}, 4);
read(IN_FILE, $bmpFileHeader{'bfReserved'}, 4);
read(IN_FILE, $bmpFileHeader{'bfOffBits'}, 4);

@buf = unpack('C4', $bmpFileHeader{'bfSize'});
$bmpFileHeader{'bfSize'} = @buf[3]*16777216 + @buf[2]*65536 +
                           @buf[1]*256      + @buf[0];

@buf = unpack('C4', $bmpFileHeader{'bfOffBits'});
$bmpFileHeader{'bfOffBits'} = @buf[3]*16777216 + @buf[2]*65536 +
                              @buf[1]*256      + @buf[0];

if ($bmpFileHeader{'bfType'} ne "BM")
{
    print "Not BMP file...\n";
    exit;
}    

#----------------------------------------------------------------------
# Reading BMP Info
#----------------------------------------------------------------------
read(IN_FILE, $buf, $bmpFileHeader{'bfOffBits'}-14);

%bmpInfo = (
    'bmiHeader', 
    'bmiColors'
);

%bmpInfoHeader = (
    'biSize', 
    'biWidth',
    'biHeight', 
    'biPlanes',
    'biBitCount',
    'biCompression',
    'biSizeImage',
    'biXPelsPerMeter',
    'biYPelsPerMeter',
    'biClrUsed',
    'biClrImportant'
);


printf("const unsigned char hexData[] =\n"); 
printf("{\n");

for($i=0; $i<(320*240/8)/8; $i++)
{
    read(IN_FILE, $buf, 8);
    @buf = unpack('C8', $buf);

    printf ("    ");

    for($j=0; $j<8; $j++)
    {

        printf sprintf "0x%02X", @buf[$j];

        if (($i!=((320*240/8/8)-1)) || ($j<7))
        {
            printf(", ");
        }
    }

    printf "\n";
}    
printf ("};\n");


exit;


