#!/usr/local/bin/perl
# Script that gets the number of exons per gene from a gtf file
# This will be used to account for alternative transcripts when determining intron-exon and exon-intron junctions (
# 06/25/14
# Ewy Mathe
use strict;
use warnings;
use Pod::Usage;
use List::Util 'max';


pod2usage("Usage: $0 in.gtf out.txt\nScript that takes in a gtf file (e.g. refseq) and outputs the number of exons per gene\n") if ((@ARGV !=2));

#Open files
open(my $in, "<", $ARGV[0]) or die "Can't open $ARGV[0] $!!";
open(my $out, ">", $ARGV[1]) or die "Can't open $ARGV[1] $!";

my $line=<$in>;
chomp($line);
my ($chrom,$temp1,$temp2,$start,$end,$temp3,$strand,$temp4,$annot)=split(/[\t]+/, $line);
my ($gid,$gname,$transid,$tssid,$exon)=split(/[;]+/,$annot);
my ($temp,$exon_num)=split(/exon_number/,$exon);
#print "$chrom\t$start\t$end\t$strand\t$exon_num\n";
my ($newchrom,$newtemp1,$newtemp2,$newstart,$newend,$newtemp3,$newstrand,$newtemp4,$newannot)=();
my ($newgid,$newgname,$newtransid,$newtssid,$newexon)=();
my ($newtemp,$newexon_num);

while(my $line=<$in>) {
	chomp($line);
	($newchrom,$newtemp1,$newtemp2,$newstart,$newend,$newtemp3,$newstrand,$newtemp4,$newannot)=split(/[\t]+/, $line);
	($newgid,$newgname,$newtransid,$newtssid,$newexon)=split(/[;]+/,$newannot);
	($newtemp,$newexon_num)=split(/exon_number/,$newexon);
	#print "$newchrom\t$newstart\t$newend\t$newstrand\t$newexon_num\n";
	if ($newgname eq $gname) {
		if ($newexon_num > $exon_num) {$exon_num=$newexon_num;}
		else {
			next;
		}
	}
	else {
		print $out "$gname\t$exon_num\n";
		$gname=$newgname;
		$exon_num=$newexon_num;
	}
}

if ($newgname eq $gname) {
	if ($newexon_num > $exon_num) {$exon_num=$newexon_num;}
	print $out "$gname\t$exon_num\n";
}

close($in) or die "Can't close $in\n";
close($out) or die "Can't close $out\n";
exit;

