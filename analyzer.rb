#!/usr/bin/env ruby

module Analyzer
  module Apache
    require_relative './lib/utils.rb'
    require_relative './lib/parsers.rb'
    require_relative './lib/aggregator.rb'

    class LogAnalyzer
      attr_reader :options

      def initialize
          @options = Options.new
          @options.parse_cl("analyzer")
          Config.load(@options.verbose)
      end

      def self.summary(num_processed, num_rejected, num_no_os)
        Utils.report_title($stdout, "Summary:")
        printf "%-#{FIELD_LENGTH}s%s\n", "", "#{num_processed} record(s) processed."
        printf "%-#{FIELD_LENGTH}s%s\n", "", "#{num_rejected} record(s) rejected."
        printf "%-#{FIELD_LENGTH}s%s\n", "", "#{num_no_os} record(s) do not contain OS information."
        printf "%-#{FIELD_LENGTH}s%s\n", "", 
           "Please see the logs files #{Config.logger_dir}/#{Config.logger_error} and #{Config.logger_dir}/#{Config.logger_info} for details."
      end

      begin
        analyzer = LogAnalyzer.new
        logger = Logger.new(Config.logger_dir, Config.logger_error, Config.logger_info)
        logger.truncate
        parser = LogParser.new(logger)
        matcher = OsMatcher.new(Config.os_list, logger)
        aggregator = Aggregator.new(Config.os_list, analyzer.options.verbose)
        aggregator.output_file = analyzer.options.output_file
        parser.each_combined_line(analyzer.options.log_file) do | line |
          host, date, method, user_agent = line
          os = matcher.os_match(user_agent)
          aggregator.add(date, method, os, user_agent)
        end
        aggregator.reports(analyzer.options.ascending)

        if analyzer.options.verbose
          summary(parser.records_processed, parser.records_rejected, matcher.agents_no_os)
        end
        rescue => e
          puts $!.message
          exit 1
      end
    end
  end
end	