#!/usr/bin/perl
# ==========================================================================
# Subversion Control:
# $Revision$
# $Date$
# ==========================================================================
#
#     This confidential and proprietary source code may be used only as
#     authorized by a licensing agreement from SEIKO EPSON CORPORATION.
#
#                (C) COPYRIGHT 2003 SEIKO EPSON CORPORATION.
#            (C) COPYRIGHT 2003 SHANGHAI EPSON ELECTRONIC CO.,LTD.
#                          ALL RIGHTS RESERVED
#
#     The entire notice above must be reproduced on all authorized copies
#     and any such reproduction must be pursuant to a licensing agreement
#     from SEIKO EPSON CORPORATION.
#
# File     : run_sim.pl
# Author   : Handsome Huang
# Abstract : Simulation running script
#
# ==========================================================================
# Modification History:
# Date        By          Change Description
# ---------------------------------------------------------------------
# 2009/08/12  Handsome    New creation.
#
# ==========================================================================

#---------------------------------------------------------------------
# Get parameters
#---------------------------------------------------------------------
$opt_m = "rtl";
$opt_d = "typ";
$opt_p = "20_000";
$opt_c = "10_000";

use File::Copy;
use Getopt::Std;
getopt('tmpcdw');

#---------------------------------------------------------------------
# Parameters check
#---------------------------------------------------------------------
if (!(defined $opt_t))
{
    print "\n";
    print "Usage: $0 [option] <ret>\n";
    print "\n";
    print "  Option: [default] Description               Setting case          \n";
    print "\n";                                
    print "      -t:           Test bench file name.                           \n";
    print "      -m: [rtl]     Simulation mode.          [rtl/ba/fpga]         \n";
    print "      -p: [20000]   Clock period [ps].                              \n";
    print "      -c: [10000]   Numner of cycles.                               \n";
    print "      -d: [typ]     Delay type.               [min/typ/max]         \n";
    print "      -w:           Waveform.                 [sscan/svision/verdi] \n";
    print "\n";
    print "Example:\n";
    print "$> ./$0 -m rtl -t sample -w svision <ret>\n";
    print "or\n";
    print "$ ./$0 -m rtl -t sample -p 10_000 -c 1000 <ret>\n";
    print "\n";
    exit;
} 

#---------------------------------------------------------------------
# Built enviroment
#---------------------------------------------------------------------
if (!(-d "../run")) 
{ 
    mkdir "../run", 0744 or die "Can not create ../run directory!!!\n";
}
chdir "../run" or die "Can not enter into ../run directory!!!\n";

$sim_dir = $opt_t;

$opt_t = "../../tb/" . $opt_t;
$opt_m = $opt_m . ".env";
$opt_p =~ s/_//; 
$sim_dir = $sim_dir . "_" . $opt_d . "_" . $opt_p/1000 . "ns";


if (-d $sim_dir)
{
    chdir $sim_dir or die "Can not enter into $sim_dir directory!!!\n";
    unlink (<*>);
}
else
{
    mkdir $sim_dir, 0744 or die "Can not create $sim_dir directory!!!\n";
    chdir $sim_dir or die "Can not enter into $sim_dir directory!!!\n";
}


copy("../../env/$opt_m", "./$opt_m");
chmod 0744, "$opt_m";


$sim_dgn = $opt_m;
$sim_dgn =~s/.env$/.dgn/;
system("./$opt_m > $sim_dgn");


if (-s $sim_dgn)
{
    open(DGNFILE,">>$sim_dgn") or die "Can not open $sim_dgn file!!!\n";

    print DGNFILE "+define+CYCLE=$opt_p\n";
    print DGNFILE "+define+CYCNUM=$opt_c\n";

    SWITCH_DELAY:
    {    
        if ($opt_d eq "typ") { print DGNFILE "+typdelays\n"; print DGNFILE "+define+TYPSDF\n"; last SWITCH_DELAY; }
        if ($opt_d eq "min") { print DGNFILE "+mindelays\n"; print DGNFILE "+define+MINSDF\n"; last SWITCH_DELAY; }
        if ($opt_d eq "max") { print DGNFILE "+maxdelays\n"; print DGNFILE "+define+MAXSDF\n"; last SWITCH_DELAY; }
    }

    SWITCH_WAVEFORM:
    {    
        if ($opt_w eq "sscan"  ) { print DGNFILE "+define+SSCAN\n";   last SWITCH_WAVEFORM; }
        if ($opt_w eq "svision") { print DGNFILE "+define+SVISION\n"; last SWITCH_WAVEFORM; }
        if ($opt_w eq "verdi"  ) { print DGNFILE "+define+VERDI\n";   last SWITCH_WAVEFORM; }
    }

    close(DGNFILE);
}
else
{
    print "Environment error, please check $opt_m file!!!\n";
    exit;
}
  
print "\n";
print " <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"; 
print " <<              Set-up the Simulation Enviroment             >>\n"; 
print " <<                   Starting Simulation                     >>\n"; 
print " <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"; 
print "\n";

system ("ncverilog -f $sim_dgn $opt_t.v");

#rm *.o
##rm *.X
system ("rm -r INCA_libs");
#mkdir ./.tmp
#mv *.log ./.tmp
# 
##gzip *
#mv ./.tmp/* .
#rm -r ./.tmp
# 
#TIM=`pwd`
#df -k $TIM | grep seelinux
#echo
#echo
          

