#!/usr/bin/env ruby

module Analyzer
  module Apache
    require_relative './lib/utils.rb'
    require_relative './lib/parsers.rb'
    require_relative './lib/aggregator.rb'

    class LogAnalyzer
      attr_reader :options

      def initialize
          @options = Analyzer::Options.new
          @options.parse_cl("analyzer")
          Analyzer::Config.load(@options.verbose)
      end

      def self.summary(num_processed, num_rejected, num_no_os)
        Analyzer::Utils.report_title($stdout, "Summary:")
        printf "%-#{Analyzer::FIELD_LENGTH}s%s\n", "", "#{num_processed} record(s) processed."
        printf "%-#{Analyzer::FIELD_LENGTH}s%s\n", "", "#{num_rejected} record(s) rejected."
        printf "%-#{Analyzer::FIELD_LENGTH}s%s\n", "", "#{num_no_os} record(s) do not contain OS information."
        printf "%-#{Analyzer::FIELD_LENGTH}s%s\n", "", 
           "Please see the logs files #{Analyzer::Config.logger_dir}/#{Analyzer::Config.logger_error} and #{Analyzer::Config.logger_dir}/#{Analyzer::Config.logger_info} for details."
      end

      begin
        analyzer = Analyzer::Apache::LogAnalyzer.new
        logger = Analyzer::Logger.new(Analyzer::Config.logger_dir, Analyzer::Config.logger_error, Analyzer::Config.logger_info)
        logger.truncate
        parser = Analyzer::Apache::LogParser.new(logger)
        matcher = Analyzer::Apache::OsMatcher.new(Analyzer::Config.os_list, logger)
        aggregator = Analyzer::Aggregator.new(Analyzer::Config.os_list, analyzer.options.verbose)
        aggregator.output_file = analyzer.options.output_file
        parser.each_combined_line(analyzer.options.log_file) do | line |
          host, date, method, user_agent = line
          os = matcher.os_match(user_agent)
          aggregator.add(date, method, os, user_agent)
        end
        aggregator.reports

        if analyzer.options.verbose
          LogAnalyzer.summary(parser.records_processed, parser.records_rejected, matcher.agents_no_os)
        end
        rescue => e
          puts $!.message
          exit 1
      end
    end
  end
end	