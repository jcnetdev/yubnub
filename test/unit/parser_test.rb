require File.dirname(__FILE__) + '/../test_helper'

class ParserTest < Test::Unit::TestCase
  fixtures :commands

  def setup
    @gim = Command.first(:conditions => {:name => "gim"}) 
    @cl = Command.find_or_initialize_by_name("cl")
  end
  
  # Verify that calling Parser will increment the "uses" column of the command
  def test_uses
    assert_equal 0, @gim.uses
    assert_nil @gim.last_use_date
    
    Parser.get_url('gim "porche 911"')
    @gim.reload
        
    assert_equal 1, @gim.uses
    assert_not_nil @gim.last_use_date
    assert Time.now - @gim.last_use_date < 5  # seconds
  end
  
  # Verify the parser is outputting correct URLs
  def test_parse
    assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=blah+%22ford+F-150%22', 
                 Parser.get_url('blah "ford F-150"', AppConfig.default_command)

    assert_equal 'http://images.google.com/images?q=blah+%22ford+F-150%22', 
                 Parser.get_url('blah "ford F-150"', "gim")

    assert_equal 'http://images.google.com/images?q=%22porsche+911%22', 
                 Parser.get_url('gim "porsche 911"', AppConfig.default_command)

    assert_equal 'http://bar.com?q=%22porsche%20911%22', 
                 Parser.get_url('bar "porsche 911"', AppConfig.default_command)
  end
  
  
  # Verify the parser can handle multple parameters
  def test_multiple_parameter
    @cl.url = 'http://craigslist.com?city=${city}&item=${item}'
    @cl.save
    
    assert_equal "http://craigslist.com?city=san+francisco&item=tennis+shoes",
                 Parser.get_url('cl -city san francisco  -item tennis  shoes')
    
    #
    assert_equal "http://craigslist.com?city=san+francisco&item=",
                 Parser.get_url('cl -city  san  francisco')
    
    #
    assert_equal "http://craigslist.com?city=&item=tennis+shoes",
                 Parser.get_url('cl -item  tennis  shoes')
    #
    assert_equal "http://craigslist.com?city=&item=",
                 Parser.get_url('cl')
    #
    assert_equal "http://craigslist.com?city=&item=",
                 Parser.get_url('cl foo')
    #
    assert_equal "http://craigslist.com?city=&item=",
                 Parser.get_url('cl -foo')
  end
  
  # Verify the parser can handle multple parameters with default values
  def test_multiple_parameter_with_defaults
    @cl.url = 'http://craigslist.com?city=${city}&item=${item=foo bar}'
    @cl.save
    
    assert_equal "http://craigslist.com?city=san+francisco&item=tennis+shoes",
                 Parser.get_url('cl -city  san  francisco  -item  tennis  shoes')
    
    #
    assert_equal "http://craigslist.com?city=san+francisco&item=foo+bar",
                 Parser.get_url('cl -city  san  francisco')
    
    #
    assert_equal "http://craigslist.com?city=&item=tennis+shoes",
                 Parser.get_url('cl -item  tennis  shoes')
    #
    assert_equal "http://craigslist.com?city=&item=foo+bar",
                 Parser.get_url('cl')
    #
    assert_equal "http://craigslist.com?city=&item=foo+bar",
                 Parser.get_url('cl foo')
    #
    assert_equal "http://craigslist.com?city=&item=foo+bar",
                 Parser.get_url('cl -foo')
  end
  
  def test_COMMAND_parameter
    @cl.url = 'http://craigslist.com?city=${city}&foo=${COMMAND}'
    @cl.save
    
    #
    assert_equal "http://craigslist.com?city=san+francisco&foo=cl+-city+san+francisco",
                 Parser.get_url('cl -city san francisco')
  end
  
  # Verify the parser can handle multple parameters with multiple default values
  def test_multiple_parameter_with_defaults2
    @cl.url = 'http://craigslist.com?city=${city=victoria bc=blah}&item=${item=foo bar}'
    @cl.save
    
    assert_equal "http://craigslist.com?city=san+francisco&item=tennis+shoes",
                 Parser.get_url('cl -city  san  francisco  -item  tennis  shoes')
    
    #
    assert_equal "http://craigslist.com?city=san+francisco&item=foo+bar",
                 Parser.get_url('cl -city  san  francisco')
    
    #
    assert_equal "http://craigslist.com?city=victoria+bc&item=tennis+shoes",
                 Parser.get_url('cl -item  tennis  shoes')
    #
    assert_equal "http://craigslist.com?city=victoria+bc&item=foo+bar",
                 Parser.get_url('cl')
    #
    assert_equal "http://craigslist.com?city=victoria+bc&item=foo+bar",
                 Parser.get_url('cl foo')
    #
    assert_equal "http://craigslist.com?city=victoria+bc&item=foo+bar",
                 Parser.get_url('cl -foo')
  end
  
  # Verify the parser can handle multple parameters
  def test_multiple_parameter2
    @cl.url = 'http://craigslist.com?city=${city}&item=%s'
    @cl.save
    
    assert_equal "http://craigslist.com?city=san+francisco+tennis+shoes&item=",
                 Parser.get_url('cl -city  san  francisco  tennis  shoes')
    
    #
    assert_equal "http://craigslist.com?city=&item=san+francisco+tennis+shoes",
                 Parser.get_url('cl san  francisco  tennis  shoes')
    
    #
    assert_equal "http://craigslist.com?city=san+francisco&item=tennis+shoes",
                 Parser.get_url('cl tennis  shoes  -city  san  francisco')
    #
    assert_equal "http://craigslist.com?city=&item=",
                 Parser.get_url('cl')
    #
    assert_equal "http://craigslist.com?city=&item=foo",
                 Parser.get_url('cl foo')
    #
    assert_equal "http://craigslist.com?city=&item=-foo",
                 Parser.get_url('cl -foo')
  end
  
  # Verify the parser can handle multple parameters
  def test_multiple_parameter3
    @cl.url = 'http://craigslist.com?city=${city}&item=${city}'
    @cl.save
    
    assert_equal "http://craigslist.com?city=san+francisco&item=san+francisco",
                 Parser.get_url('cl -city  san  francisco')
    
  end
  
  # TODO: convert tests

  # # Verify that the runtime substitutions work
  # def test_runtime_substitutions
  #   assert_equal "http://images.google.com/images?q=hello+world",
  #                Parser.get_url('gim {test_echo hello world}')
  #   
  # end
  # def test_runtime_substitutions
  #   get :parse, {'command' => 'gim {test_echo hello world}'}
  #   assert_equal 'http://images.google.com/images?q=hello+world', @controller.last_url
  #   assert_response :redirect
  # 
  #   get :parse, {'command' => 'gim {test_echo 1 {test_echo {test_echo 2} 3}}'}
  #   assert_equal 'http://images.google.com/images?q=1+2+3', @controller.last_url
  #   assert_response :redirect
  # 
  #   get :parse, {'command' => '{test_echo gim}'}
  #   assert_equal 'http://images.google.com/images?q=', @controller.last_url
  #   assert_response :redirect
  # 
  #   command = 'gim '
  #   1.upto(100) { |i| command += "{test_echo #{i}}" }
  #   assert_raise (RuntimeError) {
  #     get :parse, {'command' => command}
  #   }
  # end
  # def test_compile_time_substitutions
  #   command = Command.find_first("name='gim'")
  #   command.url = 'http://{test_echo foo{test_echo bar}}.com'
  #   command.save
  #   get :parse, {'command' => 'gim'}
  #   assert_equal 'http://foobar.com', @controller.last_url
  #   assert_response :redirect
  #   command = Command.find_first("name='gim'")
  #   command.url = 'http://foo.com?first=${first}&{test_echo l{test_echo as}}{test_echo t}=${last}'
  #   command.save
  #   get :parse, {'command' => 'gim -first jon -last aquino'}
  #   assert_equal 'http://foo.com?first=jon&last=aquino', @controller.last_url
  #   assert_response :redirect
  #   command = Command.find_first("name='gim'")
  #   command.url = 'http://foo.com?first=${first}&last=${last={test_echo foo bar}}'
  #   command.save
  #   get :parse, {'command' => 'gim -first jon'}
  #   assert_equal 'http://foo.com?first=jon&last=foo+bar', @controller.last_url
  #   assert_response :redirect
  #   command = Command.find_first("name='gim'")
  #   command.url = 'http://foo.com?first=${first}&last={test_echo X${last}Z}'
  #   command.save
  #   get :parse, {'command' => 'gim -first jon -last aquino'}
  #   assert_equal 'http://foo.com?first=jon&last=XaquinoZ', @controller.last_url
  #   assert_response :redirect
  #   command = Command.find_first("name='gim'")
  #   command.url = 'http://foo.com?first=${first}&last={test_echo X${last={test_echo smith jones}}Z}'
  #   command.save
  #   get :parse, {'command' => 'gim -first jon -last aquino'}
  #   assert_equal 'http://foo.com?first=jon&last=XaquinoZ', @controller.last_url
  #   assert_response :redirect
  #   get :parse, {'command' => 'gim -first jon'}
  #   assert_equal 'http://foo.com?first=jon&last=Xsmith+jonesZ', @controller.last_url
  #   assert_response :redirect
  # end
  # def test_initialize_index
  #   get :index, {'command' => 'foo'}
  #   assert_response :success
  #   assert_tag :tag => 'input', :attributes => { 'value' => 'foo' }
  # end
  # def test_takes_parameters
  #   assert(@controller.takes_parameters("goo%s"))
  #   assert(@controller.takes_parameters("goo${hello}"))
  #   assert(! @controller.takes_parameters("goo"))
  #   assert(! @controller.takes_parameters("goo$"))
  #   assert(! @controller.takes_parameters("goo{}"))
  # end
  # def test_parse_proper
  #   assert_equal 'http://maps.google.com/maps?q=vancouver&spn=0.059612,0.126686&hl=en', @controller.parse_proper('http://maps.google.com/maps?q=vancouver&spn=0.059612,0.126686&hl=en', nil)
  #   assert_equal 'http://maps.google.com', @controller.parse_proper('http://maps.google.com', nil)
  #   assert_equal 'http://maps.google.com/', @controller.parse_proper('http://maps.google.com/', nil)
  #   assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=http%3A%2F%2Fmaps.google.com', @controller.parse_proper(' http://maps.google.com', nil)
  #   assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=.net', @controller.parse_proper('.net', nil)
  #   assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=ArrayList+.net', @controller.parse_proper('ArrayList .net', nil)
  #   assert_equal 'http://ArrayList.net', @controller.parse_proper('ArrayList.net', nil)
  #   assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=ArrayList.ne8', @controller.parse_proper('ArrayList.ne8', nil)
  #   assert_equal 'http://ArrayList.nett', @controller.parse_proper('ArrayList.nett', nil)
  #   assert_equal 'http://www.google.com/search?ie=UTF-8&sourceid=navclient&gfns=1&q=ArrayList.nettt', @controller.parse_proper('ArrayList.nettt', nil)
  # end
  # def test_no_url_encoding
  #   assert_equal 'http://web.archive.org/web/*/http://www.ing.be/', combine('http://web.archive.org/web/*/%s[no url encoding]', 'http://www.ing.be/', 'foo')
  # end
  # def test_post
  #   assert_equal 'http://jonaquino.textdriven.com/sean_ohagan/get2post.php?yndesturl=http://web.archive.org/web/*/http://www.ing.be/', combine('http://web.archive.org/web/*/%s[no url encoding][post]', 'http://www.ing.be/', 'foo')
  #   assert_equal 'http://jonaquino.textdriven.com/sean_ohagan/get2post.php?yndesturl=http://foo.com?a=bar', combine('http://foo.com?a=%s[post]', 'bar', 'xxxxx')
  #   assert_equal 'http://jonaquino.textdriven.com/sean_ohagan/get2post.php?yndesturl=http://foo.com&a=bar', combine('http://foo.com&a=%s[post]', 'bar', 'xxxxx')
  # end
  # def test_url
  #   get :url, {'command' => 'gim porsche'}
  #   assert_tag :content =>'http://images.google.com/images?q=porsche'
  #   get :url, {'command' => 'gim %s'}
  #   assert_tag :content =>'http://images.google.com/images?q=%25s'
  # end
  # def test_replace_with_spaces
  #   assert_equal 'http://blah.com/harry+potter', combine('http://blah.com/%s', 'harry potter', 'foo')
  #   assert_equal 'http://blah.com/harry%20potter', combine('http://blah.com/%s[use %20 for spaces]', 'harry potter', 'foo')
  #   assert_equal 'http://blah.com/harry-potter', combine('http://blah.com/%s[use - for spaces]', 'harry potter', 'foo')
  # end  
  
  
end
