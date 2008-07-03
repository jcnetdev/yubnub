require File.join(File.dirname(__FILE__), '../../../../config/environment')
require 'rubygems'
require 'test/unit'
begin
  require 'ruby-debug'
  Debugger.start
rescue LoadError
  # no debugger for you
end

class MockRecord
  attr_writer :due_on
  def self.before_validation(*args) nil end
  
  def [](attribute)
    read_attribute(attribute)
  end
  
  protected
    def read_attribute(attribute)
      instance_variable_get("@#{attribute}")
    end
    
    def write_attribute(attribute, value)
      instance_variable_set("@#{attribute}", value)
    end
end

MockRecord.extend TzTimeHelpers::ActiveRecordMethods
MockRecord.tz_time_attributes :due_on

module TzTimeHelpers
  class ActiveRecordMethodsTest < Test::Unit::TestCase
    def setup
      TzTime.zone = TimeZone["Central Time (US & Canada)"]
      @record = MockRecord.new
      @record.instance_variable_set(:@due_on, Time.utc(2006, 1, 1))
    end
    
    def test_should_access_utc_time_as_local_with_getter_method
      assert_equal TzTime.local(2005, 12, 31, 18), @record.due_on
    end
    
    def test_should_fix_local_timezones
      @record.due_on = Time.utc(2006, 1, 1)
      assert_equal TzTime.local(2006, 1, 1), @record.due_on
      assert_equal TzTime.local(2006, 1, 1), @record[:due_on]
    end
    
    def test_should_not_fix_utc_timezones
      assert_equal Time.utc(2006, 1, 1), @record[:due_on]
    end
    def test_should_only_fix_timezones_that_have_been_written
      assert_equal TzTime.utc(2006, 1, 1), @record.due_on
    end
  end
end