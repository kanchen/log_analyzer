module Analyzer
  require 'optparse'
  FIELD_LENGTH ||= 16
  class Options
   attr_reader :log_file, :verbose, :output_file
    def parse_cl(name)

      options = {}
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: #{name}.rb [options]"

        opts.on("-l", "--log-file <log-file>", "Log file name - required") do |v|
          @log_file = v
          options["log-file"] = v
        end
        opts.on("-o", "--output-file <output-file>", "Output file name") do |v|
          @output_file = v
          options["output-file"] = v
        end
        opts.on("-v", "--verbose", "Verbose mode") do |v|
          @verbose = v
          options["verbose"] = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Help message") do
          puts opts
          exit
        end
      end

      begin
        optparse.parse!
        required = ["log-file"]
        missing = required.select{ |param| options[param].nil? }
        unless missing.empty?
          puts "Missing option(s): #{missing.join(', ')}"
          puts optparse
          exit
        end
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts $!.to_s
        puts optparse
        exit
      end
    end
  end

  class Config
    require 'psych'
    @@config
    def self.load(verbose = false)
      config_file = File.exist?("#{Dir.home}/.analyzer/config.yml") ? "#{Dir.home}/.analyzer/config.yml" : "#{Dir.pwd}/config/config.yml"
      @@config = Psych.load_file(config_file)
      if verbose
        self.print_os_mapping
      end
    end

    def self.os_list
      return @@config["os-list"]
    end

    def self.logger_dir
      return @@config["logger"]["dir"]
    end

    def self.logger_error
      return @@config["logger"]["error"]
    end
    def self.logger_info
      return @@config["logger"]["info"]
    end

    def self.print_os_mapping()
      puts "OS mappings. Modify by editing #{Dir.home}/.analyzer/config.yml or #{Dir.pwd}/config/config.yml"
      puts self.os_list.to_yaml
    end
  end

  class Logger
    @error_path
    @info_path
    def initialize(directory_name, error_file, info_file)
      # create the directory
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      @error_path = "#{directory_name}/#{error_file}"
      @info_path = "#{directory_name}/#{info_file}"
    end

    # truncate the log files. then puts timestamp line
    def truncate
      File.open(@error_path, 'w') do |f|
        f.truncate(0)
        Analyzer::Utils.timestamp(f)
      end

      File.open(@info_path, 'w') do |f|
        f.truncate(0)
        Analyzer::Utils.timestamp(f)
      end
    end

    # append content to the logger
    def error(content)
      File.open(@error_path, 'a') { |f| f.puts(content) }
    end
    def info(content)
      File.open(@info_path, 'a') { |f| f.puts(content) }
    end
  end

  class Utils
    def self.report_title (f, title, c = "+")
      f.puts "+" * (title.size + 4)
      f.puts "+ #{title} +"
      f.puts "+" * (title.size + 4)
    end

    def self.timestamp(f, c = "*")
      ts = Time.now.strftime("%d/%m/%Y %H:%M")
      self.report_title(f, ts, c)
    end
  end

end
