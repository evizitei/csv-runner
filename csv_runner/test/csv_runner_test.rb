require 'test/unit'
require File.dirname(__FILE__) + "/../lib/csv_runner"


class CsvRunnerHost
  include CsvRunner
end

class CsvRunnerTest < Test::Unit::TestCase
  def test_truth
    assert true
  end
end