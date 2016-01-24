module Analyzer
  module Apache
    require 'Date'

   	class LogParser
   		attr_accessor :verbose, :logger, :records_processed, :records_rejected

   		LOG_FORMATS = {
    		:combined => %r{^(\S+) (\S+) (\S+) \[(\S+) ([\+\-]\d{4})\] "(\S+) (\S+) ([^"]+)" (\d{3}) (\d+|-) "(.*?)" "([^"]+)"$}
  	  	}

  	  	def initialize(logger)
  	  		@logger = logger

        end

      	def each_combined_line(log_file)
  	  		@records_processed = 0
  	  		@records_rejected = 0
      		file = File.open(log_file, "r")
      		file.each_line do | line |
      			@records_processed += 1
      			data = line.scan(LOG_FORMATS[:combined]).flatten

      			begin
      				if data.empty?
      					raise "Invalid format"
      				end
      				# must be a valid date
      				date = data[3].split(':')[0]
      				DateTime.strptime(date, "%d/%b/%Y")
    	  			yield [data[0], date, data[5], data[11]]
	      		rescue
      				msg = "ERROR: #{$!.message}. #{line}"
      				if @verbose
      					puts msg
      				end
      				@logger.error(msg)
      				@records_rejected += 1
      				next
      			end
      		end
      	end
    end

    class OsMatcher
      attr_accessor :logger, :agents_no_os

      @config_list

      def initialize(config_list, logger)
        @config_list = config_list
        @logger = logger
        @agents_no_os = 0
      end

      def os_match(user_agent)
        matched = nil
        @config_list.each do | os_map |
          os_map.each do | main_os, sub_os |
            if user_agent.match(/#{main_os}/).nil?
              #try to match sub list
              if !sub_os.nil?
                sub_os.each do | os |
                  if !user_agent.match(/#{os}/).nil?
                    # count as main os. stop searching
                    matched = main_os
                    break
                  end
                end
              end
            else
              matched = main_os
              next
            end
          end
        end
        if matched.nil?
          @agents_no_os += 1
          @logger.info("INFO: No OS match. User-Agent: #{user_agent}")
        end
        return matched
      end
    end

  end
end	