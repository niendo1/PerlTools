#!/usr/bin/perl
# 2024-01-12
# 
# replaced in directory trees
#
# Parameter: (--> corresponds to possible values)
# method
# -->copy copies replaced files to copypath
# -->override copies original file to <name><backup> and
# overwrites the original file
#
# Backup these files will be ignored
# -->~
# Copypath see copy
# -->/tmp
# Options Options in regular replacement
# -->gi
#
#
# +Path         
# --> /boot/ add this path
# -->\.*$ use this file filter
# -->\.htm[l]$
#
# replace
# -->Search expression
# -->New value
#             
# replace with length of search
#
# replace with length of replace
#
# Regular Expressions: before search expression (i?)
#
use Getopt::Std;
use File::Find;
use File::Path;
use File::Copy;

use strict;

my(@arFiles);
my(@arMuster);
my($listref);
my($startdir);
my($filter);
my($backup)="~";
my($options);
my($Copypath);
my($nDatei)=0;
my($nMuster)=0;
my($methode)="copy"; # copy or override
$main::name="MultiReplace.pl 0.3";
$main::copyright="(c) 2002 by peter\@niendo.de under GPLv3";


$main::tempfile="/tmp/replace.tmp";

system 'echo "" >'.$main::tempfile;
wait;

#
# p : path
# f : filter
# s : suchmuster
# r : replace
# c : config.datei
# t : test

my($Filename)=$0;
getopts("t:p:m:f:c:");

if ($main::opt_c eq "") 
     {
      usage($Filename);
      exit;
      }

einlesen_muster() ;
#$nMuster=0;
#$nDatei=0;
foreach $listref (@main::arFiles)
  {
    my ($listrefneu);
    if($main::methode eq "override") {
       $listrefneu=$listref.$main::backup;
    } else {
       $listrefneu=$main::Copypath.$listref;
    }   
    if(copy($listref,$listrefneu))  {
     if($main::methode eq "override") {
       ErsetzeInDatei($listrefneu,$listref);
     } else { 
       ErsetzeInDatei($listref,$listrefneu);
     }  
    }
    else
   {
   print "\n$listrefneu could not be created, ignore... ";
   }
  }
 print "\nCount files: $nDatei";
 print "\nCount replacements: $nMuster";

 print "\n$main::name";
 print "\n$main::copyright\n";
 exit; 

# Ende

sub fc 
 {
  my($Path)=$main::startdir;
  my($Filter)=$main::filter;
  my($Filename)= $_;
  if (-d) {
        mkpath("$main::Copypath$main::startdir$Filename",1,0777);
        print "\nCreate: $main::Copypath$main::startdir$Filename";
        return;
      }
   return if ((not (-f)) || ($Filename=~/$main::backup\B/) || (!($Filename=~/$Filter/)));
   push(@main::arFiles,$File::Find::dir."/".$Filename);
 }

sub einlesen_muster()
 {
#    my($musterdatei)=$_;
    my($suche,$ersetze,$string1,$option,$i);
    open(DATA1,$main::opt_c) || die "Can't open $!\n";
    while($string1=<DATA1>)
    {

           if($string1 =~ /^#/)
            {
              $string1 ="";
            }

       if($string1 =~ /^Backup/)
        {
          chop($main::backup=<DATA1>);
        }

     if($string1 =~ /^\+Path/)
        {
          my($dir);
          chop($dir=<DATA1>);
          chop($main::filter=<DATA1>);
          system 'ls '.$dir.' -d -a -R >>'.$main::tempfile;
          wait;
          open(LESEN,$main::tempfile) ? print "\n$main::tempfile OK" : print "\n$main::tempfile FAILED" ;
          $string1=<LESEN>;
          while(chop($string1=<LESEN>))
         {
            # push(@main::arFiles,$string1);
            $main::startdir=$string1;
	        find(\&fc,$main::startdir);
         }
           close(LESEN);
	  print "\nFilter: $main::filter";      
        }
    if($string1 =~ /^Options/)
        {
          chop($main::options=<DATA1>);
        }
    if($string1 =~ /^Methode/)
        {
          chop($main::methode=<DATA1>);
        }

    if($string1 =~ /^Copypath/)
        {
          chop($main::Copypath=<DATA1>);
        }
     if($string1 =~ /^replace/)   # ersetzt
        {
          chomp($suche=<DATA1>);
          chomp($ersetze=<DATA1>);
          chomp($option=<DATA1>);
	  
	  if($option eq "") { $option=$main::options };

       	  if($string1 =~ /with length of search/)   # fuer tabellen
                {
                  while(length($ersetze) < length($suche))
         	    {$ersetze.=' ';}
                     $ersetze=substr($ersetze,0,length($suche));    
                   }
       	  if($string1 =~ /with length of replace/)   # fuer tabellen
                {
                  while(length($suche) < length($ersetze))
         	    {$suche.=' ';}
                     $suche=substr($suche,0,length($ersetze));    
                   }
	  print "\nReplace: [".$suche."] mit: [".$ersetze."]";
          push(@main::arMuster,[$suche,$ersetze,$option]);
         } 
    }
  close(DATA1)	 
 }

sub usage
{
 my($Filename)=@_;
 print "\n$main::name";
 print "\n$main::copyright";
 print "\n$Filename -c <conf.-datei> [-i inputfile] [-o outputfile]\n";
}

sub ErsetzeInDatei
{
    my($LeseDatei,$SchreibDatei)=@_;
    $nDatei++;
    my ($string1);
    my ($mustref);
    my ($change) = "";
    print "\nProcessing: $LeseDatei --> $SchreibDatei";
    open(LESEN,$LeseDatei);
    open(SCHREIBEN,">".$SchreibDatei);
     while($string1=<LESEN>)
        {
	  $nMuster=0;
          foreach $mustref (@main::arMuster)
           {
	    $nMuster++;
            my ($suche,$ersetze,$option) = @$mustref;
	     my($test);
	    if(!$option =~ /noreg/)
	      {
                 $test="\$string1 =~ s/$suche/$ersetze/$option";
 	      }
	      else
	      {
                 $test="\$string1 =~ s/\$suche/\$ersetze/$option"; 
	      }
                 eval($test);

	    $string1=~ $suche;
           }
          print SCHREIBEN $string1;
	 } 
     close(LESEN);    
     close(SCHREIBEN); 
     return;
 } # Ende Ersetze in Datei;
