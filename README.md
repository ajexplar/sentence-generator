# sentence-generator

A perl CLI script that, given a somewhat sizable corpus of text to learn from, can output a somewhat reasonable approximation of an English sentence. The sentences can range anywhere from gibberish to chatbot-esque.

## Example
perl markov.pl -c 2 file1.txt file2.txt file3.txt

## Inputs
The user has to provide a length for the Markov process's inputs that analyzes the dataset that trains the script. This is parameter -c. A Markov process is memoryless, so the outcome is dependent only on current inputs. This length parameter determines how many words are in the input. The longer the chain length, the more reasonable the sentence becomes, but it also slows down the script.

Following the length parameter, the user can provide any number of files. These files will be used as training datasets. Again, the longer the files, the better the results, but the more time it will take to process.