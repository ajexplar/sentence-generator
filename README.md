# sentence-generator

A perl shell script that, given a somewhat sizable corpus of text to learn from, can output a somewhat reasonable approximation of an English sentence. The sentences can range anywhere from gibberish to chatbot-esque.

## Example
perl markov.pl -c 2 file1.txt file2.txt file3.txt

## Inputs
The user has to provide a length for the Markov chain process before the script can analyze the training files. This is parameter -c. A Markov process is memoryless, so the next word to be added is dependent solely on the number of previous words and how often they occur together, probabalistically. The longer the chain length, the more reasonable the sentence becomes, but it does take longer to finish.

After the length parameter, the user can the names of any number of files. These files will be used as training datasets. Again, the longer the files, the better the results, but the more time it will take to process.

## Output
A single sentence will be created based off the above criteria. It will conclude with punctuation or 150 characters, whatever comes first.

