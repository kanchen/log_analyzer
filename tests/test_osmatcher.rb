require "./lib/parsers.rb"
require "./lib/utils.rb"
require "test/unit"

class TestOsMatcher < Test::Unit::TestCase

  def setup
    @os_list = [{"Linux" => nil}, {"Windows" => nil}, {"iOS" => ["iPhone OS"]}]

    @log_dir = "tests/logs"
    @error_file = "test_error.log"
    @info_file = "test_info.log"
    @test_log_file = "tests/test_sample.log"
    @logger = Analyzer::Logger.new(@log_dir, @error_file, @info_file)
    @matcher = Analyzer::Apache::OsMatcher.new(@os_list, @logger)
  end

  def teardown
    File.delete("#{@log_dir}/#{@info_file}")
  end

  def test_os_match

    data = [ ["Linux", "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.19; aggregator:Spinn3r (Spinn3r 3.1)"],
      ["Windows", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; KKman2.0)"],
      ["iOS", "Mozilla/5.0 (compatible; iOS 1.0; Ezooms/1.0; ezooms.bot@gmail.com)"],
      ["iOS", "Mozilla/5.0 (compatible; iPhone OS 2.1; Ezooms/1.0; ezooms.bot@gmail.com)"]]

    data.each do |d|
      assert_equal(d[0], @matcher.os_match(d[1]))
    end
    assert_nil(@matcher.os_match("Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"))
    assert_equal(1, @matcher.agents_no_os)
    assert(!File.file?("#{@log_dir}/#{@error_file}"))
    assert(File.file?("#{@log_dir}/#{@info_file}"))
  end

end