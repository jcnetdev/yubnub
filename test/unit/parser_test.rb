require File.dirname(__FILE__) + '/../test_helper'

class ParserTest < Test::Unit::TestCase
  fixtures :commands

  def setup
  end

  def test_truth
    assert true
  end
  
  def test_google_ford
    
  end
  
  # get :parse, {'command' => 'blah "ford F-150"'}
  # assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=blah+%22ford+F-150%22', @controller.last_url
  # get :parse, {'command' => 'blah "ford F-150"', 'default' => 'gim'}
  # assert_equal 'http://images.google.com/images?q=blah+%22ford+F-150%22', @controller.last_url
  # assert_response :redirect
  # get :parse, {'command' => 'gim "porsche 911"'}
  # assert_equal 'http://images.google.com/images?q=%22porsche+911%22', @controller.last_url
  # assert_response :redirect
  # get :parse, {'command' => 'bar "porsche 911"'}
  # assert_equal 'http://bar.com?q=%22porsche%20911%22', @controller.last_url
  # assert_response :redirect
  
end
