#Version : 09/06/2017
#ewm.pl find exact word matches from a reads file [reads.fasta] in a database file [db.fasta]

#ewm.pl [db.fasta] [reads.fasta] 

#$ARGV[0]  = db.fasta
#$ARGV[1] = reads.fasta 

my $db_id = (split(/\./,$ARGV[0]))[0];
my $reads_id = (split(/\./,$ARGV[1]))[0];

#..1.. make database fasta file a file with the genome in one line 
#cat all_viruses.fna | perl -ne 'unless ($_=~/^\>/) {chop;} print $_;'| perl -ne ' $_=~s/(?<=.)\>/\n\>/g; print $_; END{print "\n"} ' 

open (DB, "$ARGV[0]");
open (DB_ONELINE, ">oneline_$db_id.fasta");

$/="\n>";

foreach (<DB>) {
$_=~s/^>//;
chomp;
my @fields=split(/\n/,$_);
my $head=shift @fields;
print DB_ONELINE ">$head\n";
print DB_ONELINE foreach(@fields);
print DB_ONELINE "\n";
}
close (DB_ONELINE);
close (DB);

$/="\n";

#..2.. open reads file and compare to the oneline database, save results in a hash 

my %hits = (); #hash where the key is the read name and contents are the grep hits 

open (READS, "$ARGV[1]");

$/="\n>";

my $count = 0;

foreach (<READS>) {
$_=~s/^>//;
chomp;
my @fields=split(/\n/,$_);
my $head=shift @fields;
#print DB_ONELINE ">$head\n";
my $seq=join('',@fields);
my $part=substr($seq,0,200);
#print DB_ONELINE foreach(@fields);
$gp=`grep -B 1 '$part' oneline_$db_id.fasta | grep '>' | cut -d ' ' -f 1 | cut -c2- `;
#$run="grep -B 1 '$part' oneline_$db_id.fasta | grep '>' | cut -d ' ' -f 1 | cut -c2- ";
#print "$run\n";
#system $run;
#print "$gp\n";
$hits{$head} = $gp;
$count++;
print "done read $count\n";
}
$/="\n";

#while( my( $key, $value ) = each %hits ){
#    print "$key:$value\n";
#}

close (READS);

#..3.. count the unique and repeated hits and print two different lists

my %unico; #hash where key is the genome id and contents are the unique hits
my %repetido; #hash where key is the genome id and contents are all hits (unique and repeated)

for(keys %hits){
#the ley is : $_ 
#the contents are : $hits{$_}
chomp ($hits{$_});
my @fields = split (/\n/,$hits{$_});
my $num_hits = scalar @fields;

if ($num_hits == 1){
if (exists $unico{$fields[0]}){
$unico{$fields[0]}++;
} else {
$unico{$fields[0]}=1;
}

}
foreach my $j (@fields){
if (exists $repetido{$j}){
$repetido{$j}++;
} else {
$repetido{$j}=1;
}
} 
}

open (HITS_UNICO, "> hitunico-vs-$db_id-$reads_id.tab");
while( my( $key, $value ) = each %unico ){
    print HITS_UNICO "$value\t$key\n";
}
close (HITS_UNICO);

open (HITS_REPETIDO, "> hitrepetido-vs-$db_id-$reads_id.tab");
while( my( $key, $value ) = each %repetido ){
    print HITS_REPETIDO "$value\t$key\n";
}
close (HITS_REPETIDO);
