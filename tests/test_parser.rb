require "./lib/parsers.rb"
require "./lib/utils.rb"
require "test/unit"

class TestLogParser < Test::Unit::TestCase

  def setup
    @log_dir = "tests/logs"
    @error_file = "test_error.log"
    @info_file = "test_info.log"
    @test_log_file = "tests/data/test_sample.log"
    @logger = Analyzer::Logger.new(@log_dir, @error_file, @info_file)
    @parser = Analyzer::Apache::LogParser.new(@logger)
  end

  def teardown
    File.delete("#{@log_dir}/#{@error_file}")
  end

  def test_each_combined_line
    @parser.each_combined_line(@test_log_file) do | line |
          host, date, method, user_agent = line
    end
    assert_equal(10, @parser.records_processed)
    assert_equal(4, @parser.records_rejected)
    assert(File.file?("#{@log_dir}/#{@error_file}"))
    assert(!File.file?("#{@log_dir}/#{@info_file}"))
  end

end