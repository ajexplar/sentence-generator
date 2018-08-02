use strict;
use warnings;
use Getopt::Long;

sub determineWordOccurrences {
	# given a chain length N and list of words from training texts, creates two
	# keys: one that contains every N words and the following word, mapped to
	# the number of times this combination of keys occurs. The total occurrence
	# of the N-word key is stored to calculate the probability later
	my ($chain, $wordsRef) = @_;
	
	my $keySize = 0;
	my @words = @$wordsRef;

	my %mHash;
	my %oHash;
	my @mKeyArray;

	foreach my $nextWord (@words) {
		if ($keySize >= $chain) {
			my $markovKey = join(" ", @mKeyArray);
			if(exists $mHash{$markovKey} && defined $mHash{$markovKey}{$nextWord}) {
				$mHash{$markovKey}{$nextWord} += 1;
			} else {
				$mHash{$markovKey}{$nextWord} = 1;
			}
			$oHash{$markovKey} += 1;
			# remove the earliest word and replace it with the latest in the first key
			shift(@mKeyArray);
			push(@mKeyArray, $nextWord);
			$keySize = $chain;

		} else {
			push(@mKeyArray, $nextWord);
			$keySize += 1;
		}
	}

	return (\%mHash, \%oHash);
}

sub calculateTransitionProbabilities {
	# given the word order sequence mapping and the N word occurrences, divide
	# by the total to get the probability of each sequence
	my ($instRef, $occurRef) = @_;

	my %instHash = %$instRef;
	my %occurHash = %$occurRef;

	foreach my $id (keys %instHash) {
		my $chance = 0;
		my $total = 0;
		for my $next (keys %{$instHash{$id}}) {
			$instHash{$id}{$next} = ($instHash{$id}{$next} / $occurHash{$id}) + $total;
			if($total == 0) {
				# this smallest probability is added to the others to chose an
				# option via random number
				$chance = $instHash{$id}{$next};
			}
			$total += $chance;
		}
	}
}

sub displayTransitionProbabilities {
	# displays the probabilities of the given word orderings
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
	# given the word ordering and their probabilities, select an initial 
	# ordering at random. One with a capital letter is chosen to start. This
	# starts the generated sentence. The sentence is built until it reaches
	# punctuation or passes 150 characters, then returns for output, etc
	my (%params) = @_;

	my @allKeys = keys %params;

	if(!@allKeys) {
		# there could be cases where we've ended up with no keys
		return '';
	}

	my $randKey = '';
	while($randKey !~ /^[A-Z].*[^"]$/) {
	 	$randKey = $allKeys[rand @allKeys];
	}

	my $sentence = $randKey;

	my $randNum = 0;
	my @trKeyArray = split(/\s+/, $sentence);

	while($sentence !~ /.*[.!?\)"]$/ && length($sentence) <= 150) {
		$randNum = rand();
		my $trKey = join(" ", @trKeyArray);
		if(!keys %{$params{$trKey}}) {
			# in case we've exhausted the file input but haven't reached a
			# natural ending point, return the sentence as-is
			return $sentence;
		}
		for my $nxt (keys %{$params{$trKey}}) {
			if($params{$trKey}{$nxt} >= $randNum) {
				shift(@trKeyArray);
				push(@trKeyArray, $nxt);
				$sentence = $sentence . " " . $nxt;
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

my @allWords;
my @fileContent;

for my $filename(@files) {
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
	# capitalize the very first word to make parsing it easier
	$allWords[0] = uc $allWords[0];
}

my ($markov, $occurrences) = determineWordOccurrences($chainLength, \@allWords);

calculateTransitionProbabilities(\%$markov, \%$occurrences);

# displayTransitionProbabilities(%$markov);

my $botSentence = generateSentence(%$markov);

print $botSentence;