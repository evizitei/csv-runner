$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), "..","..","mocha-0.5.6","lib")

require 'test/unit'
require 'csv'
require 'date'
require 'mocha'
require File.dirname(__FILE__) + "/../lib/csv_runner"


class CsvRunnerHost
  extend CsvRunner
  
  attr_accessor :name
  attr_accessor :birth_date
  attr_accessor :is_married
  attr_accessor :number_of_children
  attr_accessor :category 
  
  attr_accessor :static_value_1
  attr_accessor :static_value_2
  
  def get_field_map
    {:name=>self.name,:birth_date=>self.birth_date.srtftime("%m/%d/%Y"),:is_married=>(self.is_married ? "Yes" : "No"),:number_of_children=>self.number_of_children.to_s,:category=>self.category}
  end
end

class CsvRunnerTest < Test::Unit::TestCase
  
  def test_bool_extract_true
    assert CsvRunnerHost.extract_csv_bool("Y")
  end
  
  def test_bool_extract_false
    assert !CsvRunnerHost.extract_csv_bool("N")
  end
  
  def test_bool_extract_case_insensitive
    assert CsvRunnerHost.extract_csv_bool("y")
    assert !CsvRunnerHost.extract_csv_bool("n")
  end  
  
  def test_date_extract_nil
    assert_nil CsvRunnerHost.extract_csv_date(nil)
  end
  
  def test_date_extract_blank
    assert_nil CsvRunnerHost.extract_csv_date("")
  end
  
  def test_matching_format
    d = Date.civil(2008,1,1)
    assert_equal d,CsvRunnerHost.extract_csv_date("01/01/2008","%m/%d/%Y")
    assert_equal d,CsvRunnerHost.extract_csv_date("01/01/08","%m/%d/%y")
    assert_equal d,CsvRunnerHost.extract_csv_date("2008/01/01","%Y/%m/%d")
  end
  
  def test_cap_string
    assert_equal "PT",CsvRunnerHost.extract_cap_string("pt")
    assert_equal "ST",CsvRunnerHost.extract_cap_string("St")
    assert_equal "OT",CsvRunnerHost.extract_cap_string("oT")
  end
  
  def test_int
    assert_equal 13,CsvRunnerHost.extract_int("13")
  end
  
  def test_csv_run
    mapping = [{:field=>:name=,:type=>:string},
               {:field=>:birth_date=,:type=>:date},
               {:field=>:is_married=,:type=>:bool},
               {:field=>:number_of_children=,:type=>:int},
               {:field=>:category=,:type=>:cap_string}]
               
    values = [{:field=>:static_value_1=,:value=>3},
              {:field=>:static_value_2=,:value=>"Hello World"}]
              
    CSV::Reader.stubs(:parse).returns([["Name","08/09/1986","Y","13","ot"]])
    results = CsvRunnerHost.csv_run(nil,mapping,values,"%m/%d/%Y") do |acc,obj| 
      acc.push obj
    end
    
    obj = results[0]
    assert_equal "Name",obj.name
    assert_equal Date.civil(1986,8,9),obj.birth_date
    assert obj.is_married
    assert_equal 13,obj.number_of_children
    assert_equal "OT",obj.category
    assert_equal 3,obj.static_value_1
    assert_equal "Hello World",obj.static_value_2
  end
end