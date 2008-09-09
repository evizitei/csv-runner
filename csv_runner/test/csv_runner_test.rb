require 'test/unit'
require File.dirname(__FILE__) + "/../lib/csv_runner"


class CsvRunnerHost
  include CsvRunner
end

class CsvRunnerTest < Test::Unit::TestCase
  def setup
    @host =  CsvRunnerHost.new
  end
  
  def test_bool_extract_true
    assert @host.extract_csv_bool("Y")
  end
  
  def test_bool_extract_false
    assert !@host.extract_csv_bool("N")
  end
  
  def test_bool_extract_case_insensitive
    assert @host.extract_csv_bool("y")
    assert !@host.extract_csv_bool("n")
  end  
  
  def test_date_extract_nil
    assert_nil @host.extract_csv_date(nil)
  end
  
  def test_date_extract_blank
    assert_nil @host.extract_csv_date("")
  end
  
end