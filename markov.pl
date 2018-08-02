use strict;
use warnings;
use Getopt::Long;

sub determineWordOccurrences {
	my ($chain, $wordsRef) = @_;
	
	my $keySize = 0;
	my @words = @$wordsRef;

	my %mHash;
	my %oHash;
	my @mKeyArray;

	# print join("\n", @words), "\n";
	# print $chain;

	foreach my $nextWord (@words) {
		if ($keySize >= $chain) {
			my $markovKey = join(" ", @mKeyArray);
			if(exists $mHash{$markovKey} && defined $mHash{$markovKey}{$nextWord}) {
				$mHash{$markovKey}{$nextWord} += 1;
			} else {
				$mHash{$markovKey}{$nextWord} = 1;
			}
			$oHash{$markovKey} += 1;
			# print "mHash key array-@mKeyArray\n";
			shift(@mKeyArray);
			push(@mKeyArray, $nextWord);
			$keySize = $chain;

		} else {
			push(@mKeyArray, $nextWord);
			$keySize += 1;
			# print "mHash key array incremented-@mKeyArray\n";
		}
	}

	return (\%mHash, \%oHash);
}

sub calculateTransitionProbabilities {
	my ($instRef, $occurRef) = @_;

	my %instHash = %$instRef;
	my %occurHash = %$occurRef;

	foreach my $id (keys %instHash) {
		my $chance = 0;
		my $total = 0;
		for my $next (keys %{$instHash{$id}}) {
			$instHash{$id}{$next} = ($instHash{$id}{$next} / $occurHash{$id}) + $total;
			if($total == 0) {
				$chance = $instHash{$id}{$next};
			}
			$total += $chance;
		}
	}
}

sub displayTransitionProbabilities {
	my (%params) = @_;
	foreach my $k1 (keys %params) {
		print "$k1: {";
		for my $k2 (keys %{$params{$k1}}) {
			print "$k2 = $params{$k1}{$k2} ";
		}
		print "}\n";
	}
}

sub generateSentence {
	my (%params) = @_;

	my @allKeys = keys %params;

	if(!@allKeys) {
		return '';
	}

	my $randKey = '';
	while($randKey !~ /^[A-Z].*[^"]$/) {
	 	$randKey = $allKeys[rand @allKeys];
	}

	# print "randomly chose-$randKey\n";
	my $sentence = $randKey;

	my $randNum = 0;
	my @trKeyArray = split(/\s+/, $sentence);

	while($sentence !~ /.*[.!?\)"]$/ && length($sentence) <= 150) {
		$randNum = rand();
		my $trKey = join(" ", @trKeyArray);
		# print "working key-$trKey\n";
		if(!keys %{$params{$trKey}}) {
			return $sentence;
		}
		for my $nxt (keys %{$params{$trKey}}) {
			# print "Transition Key\t$trKey\nNext Word\t$nxt\nRandom Number\t$randNum\n";
			if($params{$trKey}{$nxt} >= $randNum) {
				shift(@trKeyArray);
				push(@trKeyArray, $nxt);
				$sentence = $sentence . " " . $nxt;
				# print "transition key is-@trKeyArray\n";
				last;
			}
		}
	}
	return $sentence;
}

my %args;

GetOptions(\%args, "c=s") or die "missing arguments $!";
die "usage: markov.pl -c [number > 0] [...names of files]" unless $args{c};

my $chainLength = $args{c};
if($chainLength <= 0) {
	die "chain length must be greater than zero $!";
}

my @files = @ARGV;

if(!@files) {
	die "you must provide at least one file to read from $!";
}

# print "@files\n";

my @allWords;
my @fileContent;

for my $filename(@files) {
	# print $filename;
	open FILE, $filename || die "cannot open $filename for reading $!";
	push @fileContent, $_ while (<FILE>);
	close FILE;
}

for my $line(@fileContent) {
	chomp $line;
	my @words = split(/\s+/, $line);
	push(@allWords, @words);
}

if(!@allWords) {
	die "cannot proceed with empty files $!";
} else {
	$allWords[0] = uc $allWords[0];
}

# print "@allWords\n";

my ($markov, $occurrences) = determineWordOccurrences($chainLength, \@allWords);

calculateTransitionProbabilities(\%$markov, \%$occurrences);

# displayTransitionProbabilities(%$markov);

my $botSentence = generateSentence(%$markov);

print $botSentence;