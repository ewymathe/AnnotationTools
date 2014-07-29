#!/usr/local/bin/perl
# Script that only retains the 5' most TSS and outputs a gtf file
# 07/02/14
# Ewy Mathe
use strict;
use warnings;
use Pod::Usage;
use List::Util 'max';
use List::Util 'min';

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

pod2usage("Usage: $0 all.unique.tss.bed out.gtf\nOutput is a gtf file with coordinates of the most 5' TSS\nMake sure file is sorted by gene name (column 4)") if ((@ARGV !=2));

#Open files
open(my $in, "<", $ARGV[0]) or die "Can't open $ARGV[0] !";
open(my $out, ">", $ARGV[1]) or die "Can't open $ARGV[1]!";

my %genes=(); # hash that keeps track of gene names
my @pos=(); # array that keeps track of start positions
my $posind=0; # index for @pos arrays
my $line=<$in>;
chomp($line);
my ($chr,$start,$end,$gene,$temp,$strand)=split(/\t/,$line);
if ($strand eq "+") {$pos[$posind]=$start;}
elsif ($strand eq "-") {$pos[$posind]=$end;}
else {print "ERROR! Something wrong with the strand!  Value is $strand for line $line\n";exit;}
$posind++;
my ($name,$id)=split('\|',$gene);
my ($finstart,$finend)=();
my($newchr,$newstart,$newend,$newgene,$newtemp,$newstrand)=();

while (my $line=<$in>) {
	chomp($line);
	($newchr,$newstart,$newend,$newgene,$newtemp,$newstrand)=split(/\t/,$line);
	if (exists $genes{$gene}) {print "ERROR! $gene has already been encountered!\n";exit;}
	else {
		if ($gene eq $newgene) {
			if ($newstrand eq "+") {$pos[$posind]=$newstart;}
			elsif ($newstrand eq "-") {$pos[$posind]=$newend;}
			else {print "ERROR! Something wrong with the strand!  Value is $newstrand for line $line\n";exit;}
			$posind++;
		}
		else { # new gene encountered
			($name,$id)=split('\|',$gene);
			# print "$name\t$id\n";
			if ($strand eq "+") {
				$finstart=min(@pos);
				$finend=$finstart+1;
				#print "@pos\n$finstart\t$finend\n";
			}
			elsif ($strand eq "-") {
				$finstart=(max(@pos))-1;
				$finend=$finstart+1;
				#print "@pos\n$finstart\t$finend\n";
			}
			else {print "ERROR! Something wrong with the strand!  Value is $newstrand for line $line\n";exit;}
			print $out "$chr\tusc_refseq\texon\t$finstart\t$finend\t.\t$strand\t.\tgene_id \"$id\"; gene_name \"$name\"; transcript_id \"NR_000\"; tss_id \"tss_000\"; exon_number 1\n";
			$chr=$newchr; $start=$newstart; $end=$newend; $gene=$newgene;$strand=$newstrand;
			
			@pos=();$posind=0;
			if ($strand eq "+") {$pos[$posind]=$start;}
			elsif ($strand eq "-") {$pos[$posind]=$end;}
			else {print "ERROR! Something wrong with the strand!  Value is $strand for line $line\n";exit;}
			$posind++;
		}
	}
}
# print last array
if ($newstrand eq "+") {
	$finstart=min(@pos);
	$finend=$finstart+1;
	#print "@pos\n$finstart\t$finend\n";
}
elsif ($newstrand eq "-") {
	$finstart=(max(@pos))-1;
	$finend=$finstart+1;
	#print "@pos\n$finstart\t$finend\n";
}
else {print "ERROR! Something wrong with the strand!  Value is $strand for line $line\n";exit;}
($name,$id)=split('\|',$newgene);
print $out "$newchr\tusc_refseq\texon\t$finstart\t$finend\t.\t$newstrand\t.\tgene_id \"$id\"; gene_name \"$name\"; transcript_id \"NR_000\"; tss_id \"tss_000\"; exon_number 1\n";


close($in) or die "Can't close $in\n";
close($out) or die "Can't close $out\n";
exit;

