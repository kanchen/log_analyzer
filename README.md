# Log Analyzer

This command line tool parses Apache web server access log files then presents the following info to the user:

* The number of requests served by day
* The top three(3) most frequent User Agents by day
* The ratio of GET's to POST's by OS by day

##Usage of the tool:
```
Usage: analyzer.rb [options]
    -l, --log-file <log-file>        Log file name - required
    -o, --output-file <output-file>  Output file name
    -a, --ascending                  Report date in ascending order(default descending)
    -v, --verbose                    Verbose mode

Common options:
    -h, --help                       Help message
```

![Alt text](/data/help-screen.jpg?raw=true "Help Screenshot")

## Typical usage

### Process a log file and presents the result on the console screen
The following command processes the log file **data/sample.log** and presents the result on the stdout

`./analyzer.rb -l data/sample.log`

![Alt text](/data/regular-screen.jpg?raw=true "Result Screenshot")

### Process a log file and output the result to a file
The following command process the log file **data/sample.log**, and outputs the result to **data/results.txt** file. The screenshot uses 
**cat data/results.tx** to show the result.

`./analyzer.rb --log-file data/sample.log --output-file data/results.txt`

![Alt text](/data/output-file.jpg?raw=true "Result Screenshot")

### Process in verbose mode
The **--versose** or **-v** command switch can be used to turn on verbose mode. The following two commands perform exactly the same as above cases except it outputs additional information to stdout

`./analyzer.rb -l data/sample.log -v`

![Alt text](/data/verbose-screen.jpg?raw=true "Result Screenshot")

`./analyzer.rb -l data/sample.log -v -o data/results.txt`

![Alt text](/data/verbose-with-output-screen.jpg?raw=true "Result Screenshot")

### Sort dates ascending mode
The **--ascending** or **-a** command switch can be used to sort dates in the ascending order. By default, dates are sorted in the descending order(most recently first)

`./analyzer.rb --log-file data/sample.log --ascending`

![Alt text](/data/ascending.jpg?raw=true "Result Screenshot")

`./analyzer.rb --log-file data/sample.log --output-file data/results.txt -a`

![Alt text](/data/ascending-file.jpg?raw=true "Result Screenshot")

##Install and Build
Clone this github project. This tool is developed using Ruby 2.0. It requires the Ruby gem of **psych** to parse an YMAL configuration file(see Configuration). Please refer to [https://rubygems.org/gems/psych/versions/2.0.17] for the gem installation.
Make sure **analyzer.rb** is executable, or invoke it with Ruby.

##Testing
Unit testing can be performed by the following command in the directory where the project is cloned to:

`ruby tests/test_all_tests.rb`

![Alt text](/data/unit-testings.jpg?raw=true "Result Screenshot")

##Configuration
There is a configuration file **config.yml**. The tool will look for this file under user's **$HOME/.analyzer/** directory or the **config/** directory where the tool is installed if it does not exist in **$HOME/.analyzer/**. This configuration file has two sections. One section defines which directory and what log files logs go(see Result and Log Files). The other section defines how to map different key words to OS categories.

![Alt text](/data/config.jpg?raw=true "Result Screenshot")

##Result and Log Files
The result of the **data/sample.log** is contained in the file **data/restuls.txt**.
There are also the files **logs/analyzer_error.log** and **logs/analyzer_info.log**.
The error log file contains records which can not be parsed as Apache combined log format.
The info file contains records of User-Agents which do not have OS information by the current OS configuration in the **config/config.yml**.
See Configuration how to configure the log files

##Design
The tool parses the command line switches and loads the configuration file when the *analyzer* is initialized.
It then creates a *logger*, a *parser*, an *aggregator*, and a OS *matcher*.
As the *parser* parses each line in the log file, the *matcher* tries to match the OS from the User-Agent information and the *aggregator* aggregates per day information. Parsing error and/or no OS match information are sent to the *logger*. After the *parser* finishes parsing all the records,
the *aggregator* reports the collected data.
