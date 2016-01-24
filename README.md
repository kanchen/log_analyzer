# Log Analyzer

This command line tool that parses Apache web server access log files then presents the following info to the user:

* The number of requests served by day
* The top three(3) most frequent User Agents by day
* The ratio of GET's to POST's by OS by day

##Usage of the tool:

![Alt text](/data/help-screen.jpg?raw=true "Help Screenshot")

```
Usage: analyzer.rb [options]
    -l, --log-file <log-file>        Log file name - required
    -o, --output-file <output-file>  Output file name
    -a, --ascending                  Report date in ascending order(default descending)
    -v, --verbose                    Verbose mode

Common options:
    -h, --help                       Help message
```
## Typical usage

### Process a log file and presnt the result on the console screen
The following command process the log file data/sample.log and presents the result on the stdout

`./analyzer.rb --log-file data/sample.log`

### Process a log file and output the result to a file
The following command process the log file data/sample.log and outputs the result to data/results.txt file

`./analyzer.rb --log-file data/sample.log --output-file data/results.txt`

### Process in verbose mode
The --versose or -v command switch can be used to turn on verbose mode. The following two commands perform exactly the same as above cases excpet it outputs additional information to stdout

`./analyzer.rb --log-file data/sample.log --verbose`
`./analyzer.rb --log-file data/sample.log --output-file data/results.txt -v`

### Sort date ascending mode
THe --ascending or -a command switch can be used to turn sorting date in the ascending order. By default, date is sorted in the descending order(most recently first)

`./analyzer.rb --log-file data/sample.log --ascending`
`./analyzer.rb --log-file data/sample.log --output-file data/results.txt -a`

### Lastly, the help mode
THe --help or -h command switch can be used to print the usage message. If the required --log-file switch is missing, and error message is presented in addition to the help message.

`./analyzer.rb --help`

##Build
Clone the github project. This tool is developed using Ruby 2.0. It requires the Ruby gem of psych to parse an YMAL configuration file. Please refer to [https://rubygems.org/gems/psych/versions/2.0.17] for inastallation.
The only requirement to run the command tool is that it is executable on Linux machine or invoke is with Ruby
* Linux: `chmod +x anaalyzer.rb`
* Windows: `ruby anaalyzer.rb ...`

##Testing
Unit testing can be performed by the following command in the directory the project is cloned to:

`ruby tests/test_all_tests.rb`

##Configuration
There is a configuration file config.yml. The tool will look for this file under user's $HOME/.analyzer/ directory or the config/ directory where the tool is installed if it is not exist in $HOME/.analyzer/. This configuration file has two sections. One section contains where and what are the log files to produce. The other section contains how the map different key words to OS categories. Log entry parsing errors will be logged in the error file, while the info file will contains entries that OS information is not found for a User-Agent.

##Results and Screenshots
The result of the data/sample.log is contained in the file data/restul.txt. There are also the files logs/analyzer_error.log and logs/analyzer_info.log. The error log file contains records can not be parsed as Apache combined log format. The info file contains User-Agents do not have OS information by the current OS configuration in the config/config.yml
There are also several screenshots in the data directory to be reviewed.

##Design
The tool parses the command line swithes and loads the configuration file when the driver initialized. It then creates logger, parser, aggregator
os matcher. As the parser parses each line in the log file, matcher tries to match OS from user-agent and aggregator aggregates per day information. Parsing error or no match information is sent to the logger. Afer the parser finished all the records, the aggregator reports the collected data.
