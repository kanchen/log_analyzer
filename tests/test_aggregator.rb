require "./lib/aggregator.rb"
require "test/unit"

class TestAggregator < Test::Unit::TestCase

  def setup
    @os_list = [{"Linux" => nil}, {"Windows" => nil}]
    @ag = Analyzer::Aggregator.new(@os_list, true)
  end

  def teardown
    ## Nothing really
  end

  def test_clear
    @ag.clear
    assert(@ag.data_bag.empty?)
  end

  def test_add
    date1 = "01/21/2016"
    date2 = "01/22/2016"
    ua1 = "Sosospider+(+http://help.soso.com/webspider.htm)"
    ua2 = "WordPress/3.2.1; http://aviflax.com"
    @ag.clear
    @ag.add(date1, "GET", "Linux", ua1)
    @ag.add(date1, "GET", "Linux", ua2)
    @ag.add(date1, "POST", "Linux", ua1)
    assert(!@ag.data_bag.empty?)
    assert((! @ag.data_bag[date1].nil?) && (!@ag.data_bag[date1].empty?))
    assert_equal(3, @ag.data_bag[date1][:requests])
    assert_equal(2, @ag.data_bag[date1][:agents][ua1])
    assert_equal(1, @ag.data_bag[date1][:agents][ua2])
    assert_equal(2, @ag.data_bag[date1][:oses]["Linux"]["GET"])
    assert_equal(1, @ag.data_bag[date1][:oses]["Linux"]["POST"])
    assert_equal(0, @ag.data_bag[date1][:oses]["Windows"]["GET"])
    assert_equal(0, @ag.data_bag[date1][:oses]["Windows"]["POST"])

    @ag.add(date2, "GET", "Linux", ua1)
    @ag.add(date2, "POST", "Linux", ua1)
    @ag.add(date2, "POST", "Linux", ua1)
    @ag.add(date2, "GET", "Windows", ua2)
    @ag.add(date2, "POST", "Windows", ua2)

    assert_equal(5, @ag.data_bag[date2][:requests])
    assert_equal(3, @ag.data_bag[date2][:agents][ua1])
    assert_equal(2, @ag.data_bag[date2][:agents][ua2])
    assert_equal(1, @ag.data_bag[date2][:oses]["Linux"]["GET"])
    assert_equal(2, @ag.data_bag[date2][:oses]["Linux"]["POST"])
    assert_equal(1, @ag.data_bag[date2][:oses]["Windows"]["GET"])
    assert_equal(1, @ag.data_bag[date2][:oses]["Windows"]["POST"])

    #make sure date1 data does not change
    assert_equal(3, @ag.data_bag[date1][:requests])
    assert_equal(2, @ag.data_bag[date1][:agents][ua1])
    assert_equal(1, @ag.data_bag[date1][:agents][ua2])
    assert_equal(2, @ag.data_bag[date1][:oses]["Linux"]["GET"])
    assert_equal(1, @ag.data_bag[date1][:oses]["Linux"]["POST"])
    assert_equal(0, @ag.data_bag[date1][:oses]["Windows"]["GET"])
    assert_equal(0, @ag.data_bag[date1][:oses]["Windows"]["POST"])
  end

end