module Analyzer
    require 'Date'
    class Aggregator
      attr_accessor :verbose, :output_file, :data_bag

      OS_UNKOWN = "NA"
      METHODS = ["GET", "POST"]
      
      @os_list

      def initialize(os_list, verbose = false)
        @os_list = os_list
        @verbose = verbose
        @output_file = nil
        clear
      end

      def clear
        @data_bag = {}
      end

      def add(date, method, os, user_agent)
        if date.nil? || user_agent.nil? || method.nil?
          if @verbose
            puts "Invalid data to aggregate, date: #{date.to_s}, method: #{method.to_s}, user_agent: #{user_agent}."
          end
          return
        end

        if os.nil? || os.empty?
          os = OS_UNKOWN
        end

        if @data_bag.nil?
          @data_bag = {}
        end

        data = @data_bag[date]
        if data.nil?
          data = {:requests => 0, :agents => {}, :oses => nil}
        end
        #total requests
        data[:requests] += 1

        #agents
        agents = data[:agents]
        if agents[user_agent].nil?
          agents.merge!({user_agent => 0})
        end
        agents[user_agent] += 1

        data[:agents] = agents

        #only listed methods are interested
        if !METHODS.include?(method)
          return
        end

        oses = data[:oses] 
        if oses.nil?
          os_list = @os_list.map {|o| o.keys.first} + [OS_UNKOWN]
          oses = Hash[os_list.map{|o| [o,  Hash[METHODS.map{|m| [m, 0]}] ]}]
        end
        oses[os][method] += 1
        data[:oses] = oses
         #put data back into bag
        @data_bag[date] = data
      end

      #this method only returns a sorted array of key value pairs.
      # it does not change the original data_bag
      def sort_by_date (ascending = false)
        if ascending
          @data_bag.sort {|x, y| DateTime.parse(x[0]) <=> DateTime.parse(y[0])}
        else
          @data_bag.sort {|x, y| DateTime.parse(y[0]) <=> DateTime.parse(x[0])}
        end
      end

      def reports(ascending = false)
        begin
          if output_file.nil?
            f = $stdout
          else
            f = File.open(output_file, 'w')
          end
          data_list = sort_by_date(ascending)
          report_total_requests(data_list, f)
          report_top_3_agents(data_list, f)
          report_os_get_post_ratio(data_list, f)

        ensure
          if !output_file.nil?
            f.close
          end
        end
      end

      # data_list is an array of [k, v]
      def report_top_3_agents(data_list, f)
        Analyzer::Utils.report_title(f, "Three(3) Most Frequent User Agents by Day")
        f.printf "%-#{Analyzer::FIELD_LENGTH}s%-#{Analyzer::FIELD_LENGTH}s%-#{Analyzer::FIELD_LENGTH}s\n", "Date", "Requests", "User-Agent"
        data_list.each do |date, data|
          rank = 0
          (data[:agents].sort_by {|k,v| v}.reverse).each do |ag, rv|
            rank += 1
            if rank > 3
              break
            end
            f.printf "%-#{Analyzer::FIELD_LENGTH}s%-#{Analyzer::FIELD_LENGTH}s%-#{Analyzer::FIELD_LENGTH}s\n", date, rv, ag
          end
        end
      end

      # data_list is an array of [k, v]
      def report_total_requests(data_list, f)
        Analyzer::Utils.report_title(f, "Number of Requsts Servered by Day")
        f.printf "%-#{Analyzer::FIELD_LENGTH}s%-#{Analyzer::FIELD_LENGTH}s\n", "Date", "Requests"
        data_list.each do |date, data|
          f.printf "%-#{Analyzer::FIELD_LENGTH}s%-#{Analyzer::FIELD_LENGTH}s\n", date, data[:requests]
        end
      end

      def report_os_get_post_ratio(data_list, f)
        Analyzer::Utils.report_title(f, "GET to POST Ratio by OS by Day")
          f.printf "%-#{Analyzer::FIELD_LENGTH}s", "Date"
          (@os_list.map {|o| o.keys.first} + [OS_UNKOWN]).each do |o|
            f.printf "%-#{Analyzer::FIELD_LENGTH}s", "#{o} G/P"
          end
          f.printf "\n"

          data_list.each do |date, data|
            f.printf "%-#{Analyzer::FIELD_LENGTH}s", date
            (@os_list.map {|o| o.keys.first} + [OS_UNKOWN]).each do |o|
              no_gets = data[:oses][o]["GET"]
              no_posts = data[:oses][o]["POST"]
              ratio = no_posts == 0 ? "-" : (no_gets.to_f / no_posts.to_f).round(3)
             f.printf "%-#{Analyzer::FIELD_LENGTH}s", ratio
            end
            f.printf "\n"
          end
      end
  end
end