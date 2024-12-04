#!/usr/bin/perl
# 2024-01-12
# 
# Mail merge function
# 
# Takes a txt file and replaces all placeholders via a list
# and outputs everything one after the other - or in separate files
# 
# Example cat Liste.csv | ./ListReplace.pl -c Eingang.txt -f "'@KESSEL@' eq 'ssss' -o @KESSEL@.txt


use Getopt::Std;
use File::Find;
use File::Path;
use File::Copy;

use strict;

my(@arFiles);
my(@HEADER);
my(@ERSETZE);
my(@arMuster);
my($listref);
my($startdir);
my($ZeileListe);
my($backup)="~";
my($options);
my($Copypath);
my($nDatei)=0;
my($filterOk);
my($outputfile);
my($methode)="override"; # copy
$main::name="ListReplace.pl 0.3";
$main::copyright="(c) 2024 by peter\@niendo.de under GPLv3";

#
# p : path
# f : filter
# s : suchmuster
# r : replace
# c : config.datei
# t : test

my($Filename)=$0;
getopts("t:p:m:f:c:h:o:");

if ($main::opt_c eq "") 
     {
      usage($Filename);
      exit;
      }

if ($main::opt_h ne "") 
     {
   Header();
  }

open(INPUT,"-");
$ZeileListe=<INPUT>;

@MAIN::HEADER = split(";",$ZeileListe);
@MAIN::HEADER = map { '@' . $_ . '@' } @MAIN::HEADER; # füge beim Tabellenkopf die @-Zeichen dazu

  while($ZeileListe=<INPUT>)
  {      

     if ($main::opt_o eq "") {
         $outputfile="";
     } else {
         $outputfile=ErsetzeInString($ZeileListe, $main::opt_o);
     }

     $filterOk=1;
     if ($main::opt_f ne "") {
         $filterOk = eval(ErsetzeInString($ZeileListe, $main::opt_f)); 
     }
     if ($filterOk) {
         ErsetzeInDatei($ZeileListe, $outputfile);
     }
  }
 
close(INPUT);

 exit; 

# Ende


sub usage
{
 my($Filename)=@_;
 print "\n$main::name";
 print "\n$main::copyright";
 print "\ncat <liste.csv> | $Filename -c <input.txt> [-h header] [-f filter] [-o output]\n";
}

sub ErsetzeInDatei($)
{
    my ($ersetzString,$SchreibDatei) = @_;
    $MAIN::nDatei++;
    my ($mustref);
    my ($nMuster);
    my ($change) = "";
    my ($suche,$ersetze,$option);
    my ($string1);

    my (@ERSETZE) = split(";",$ersetzString);

    open(LESEN,$main::opt_c);
    if($SchreibDatei ne "") {
       open(SCHREIBEN,">".$SchreibDatei);
    }
     while($string1=<LESEN>)
        {
  	      $nMuster=0;        
          foreach $ersetze (@ERSETZE)
           {
            $suche=@MAIN::HEADER[$nMuster];
          
            $option="igo";
	        $nMuster++;

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

	    $string1 =~ $suche;
           }
         if($SchreibDatei ne "") {   
             print SCHREIBEN $string1;
            } else {
             print $string1;
            }
	 } 
     close(LESEN); 
     if($SchreibDatei ne "") {   
       close(SCHREIBEN); 
     }
     return;
 } # Ende Ersetze in Datei;


sub ErsetzeInString($$)
{
    my ($ersetzString, $returnStr) = @_;
    my ($mustref);
    my ($nMuster);
    my ($suche,$ersetze,$option);
    my (@ERSETZE) = split(";",$ersetzString);
    
   $nMuster=0;        
   foreach $ersetze (@ERSETZE)
      {           
            $suche=@MAIN::HEADER[$nMuster];
          
            $option="igo";
            $nMuster++;

   	        my($test);
	    if(!$option =~ /noreg/)
	      {
                 $test="\$returnStr =~ s/$suche/$ersetze/$option";
 	      }
	      else
	      {
                 $test="\$returnStr =~ s/\$suche/\$ersetze/$option"; 
	      }
       eval($test);
      $returnStr =~ $suche;
     }
     return $returnStr;

     
 } # Ende Ersetze in String;


sub Header
{
     my ($string1);
     open(LESEN,$main::opt_h);
     while($string1=<LESEN>)
        {
          print $string1;
	    } 
     close(LESEN);
     return;
 } 

