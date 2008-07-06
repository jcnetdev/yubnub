require 'net/http'
require 'uri'
class Parser
  attr_accessor :url
  attr_accessor :command
  attr_accessor :command_name
  attr_accessor :command_string

  
  def self.get_url(command_string, default = nil)
    Parser.new(command_string).parse(default).url
  end
  
  def initialize(command_string)
    self.command_string = command_string
  end
  
  def parse(default = nil)
    @default = default
    self.url = parse_proper
    return self
  end
  
  def parse_proper
    # Great idea from Michele Trimarchi: if the user types in something that looks like
    # a URL, just go to it. [Jon Aquino 2005-06-23]
    return ApplicationController.helpers.prefix_with_http_if_necessary(command_string) if command_string =~ /^[^ ]+\.[a-z]{2,4}(\/[^ ]*)?$/
    
    tokens = command_string.split
    self.command_name = tokens[0]
    args = tokens[1..-1].join(' ')

    # find command
    self.command ||= Command.by_name(self.command_name)

    if self.command
      # increment if found
      self.command.uses += 1
      self.command.last_use_date = Time.now
      self.command.save unless self.command.new_record?
    # elsif tokens.size > 1 and self.command_name and self.command_name.length < 5
    #   # tried to search for something but failed
    #   return nil
    else
      # find default if passed in
      self.command = Command.by_name(@default)
      args = command_string
    end
    
    if self.command
      # Yes, we apply {...} substitutions both in the original URL and on the command line. [Jon Aquino 2005-07-16]
      return combine(command.url, args)
    else
      return nil
    end
  end

  def self.fill_in_without_switches(command_input)
    fill_in(command_input) {|switch| "SWITCH_NOT_ALLOWED_HERE" }
  end

  # fill_in does double duty: it fills in switches and substitutions in the original URL, and fills in substitutions
  # on the command line. [Jon Aquino 2005-07-16]
  def fill_in(s)
    n = 0
    while s =~ /(\$?\{([^{}]+)\})/
      match = $1
      if match[0..0] == '$'
        # A switch [Jon Aquino 2005-07-16]
        s.gsub!(match, yield(match))
      else
        # A substitution [Jon Aquino 2005-07-16]
        s.gsub!(match, response_text(match[1..-2]))
      end
      n += 1
      if n > 50
        # Protection against one form of recursion attack [Jon Aquino 2005-07-16]
        raise 'Max number of substitutions reached'
      end
    end
    return s
  end
  
  def response_text
    # We can't make a real echo command for our unit tests because of the
    # WEBrick limitation mentioned above. [Jon Aquino 2005-07-16]
    if command_string =~ /^test_echo (.+)$/
      return $1
    end
    # strip the string e.g. random.org's output ends with a newline. [Jon Aquino 2005-07-23]
    # Thanks to Sean O'Hagan for finding a critical bug here -- I was limiting the length of
    # text snippets to 200 characters -- this is way too small, cutting off URLs created by
    # complex commands (notably splitv). Bumping it up to 10000. We still want to restrict it
    # somewhat to prevent abuse. [Jon Aquino 2006-01-26]
    fetch(parse_proper(command_string, nil)).body.strip[0..10000]
  end
  
  # If you are using WEBrick to run YubNub (i.e. if you are running YubNub in
  # development mode), you may find that command substitutions will hang the
  # app. For more information, see "timeout due to deadlocking on performing
  # a net::http rails request inside a request", http://dev.rubyonrails.com/ticket/506
  # [Jon Aquino 2005-07-16]

  # If someone attempts a recursion attack (running a command that calls itself)

  # Code for #fetch is from http.rb [Jon Aquino 2005-07-16]
  def fetch( uri_str, limit = 10 )
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    response = get_response(URI.parse(uri_str))
    case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end

  def get_response(uri)
    Net::HTTP.new(uri.host, uri.port).start {|http|
      # Set timeouts (in seconds) to mitigate recursion attacks [Jon Aquino 2005-07-16]
      http.open_timeout = 10
      http.read_timeout = 10
      return http.request(Net::HTTP::Get.new(uri.request_uri))
    }
  end
  
  def takes_parameters(url)
    return url =~ /%s/ || url =~ /\$\{/
  end

  def combine(url, args)
    if url.gsub!('[post]', '')
      url = 'http://jonaquino.textdriven.com/sean_ohagan/get2post.php?yndesturl=' + url
    end

    # Suggestion from C Callosum: allow space to be converted to %20 rather than + [Jon Aquino 2005-07-01]
    space_char = '+'
    if url =~ /(\[use (.+) for spaces\])/
      space_char = $2
      url.gsub!($1, '')
    end

    # Suggestion from Wim Van Hooste: allow url-encoding to be turned off. [Jon Aquino 2005-07-01]
    no_url_encoding = url.gsub!('[no url encoding]', '')

    # Sean O'Hagan requested a way to specify the original command as a parameter to the command,
    # for his parser.php script. [Jon Aquino 2005-07-10]
    url.gsub!('${COMMAND}', post_process(command_string, space_char, no_url_encoding))
    switch_to_value_hash = switch_to_value_hash(url, args)
    url.gsub!('%s', post_process(switch_to_value_hash['%s'].join(' '), space_char, no_url_encoding))
    url = fill_in(url) { |switch|
      # Christopher Church suggested the syntax for default values: ${name=default} [Jon Aquino 2005-07-05]
      switch_proper, default_value = switch[2..-2].split('=')
      switch_proper = "${#{switch_proper}}"
      value = (switch_to_value_hash[switch_proper] == [] and not default_value.nil?) ?
            default_value :
            switch_to_value_hash[switch_proper].join(' ')
      post_process(value, space_char, no_url_encoding)
    }
    return url
  end
  
  def switch_to_value_hash(url, args)
    switch_to_value_hash = empty_switch_to_value_hash(url)
    current_switch = '%s'
    args.split.each do |arg|
      if arg[0..0] == '-' and switch_to_value_hash.has_key? "${#{arg[1..-1]}}"
        current_switch = "${#{arg[1..-1]}}"
      else
        switch_to_value_hash[current_switch] << arg
      end
    end
    return switch_to_value_hash
  end
  
  def empty_switch_to_value_hash(original_url)
    switch_to_value_hash = { '%s' => [] }
    url = String.new(original_url)
    while url.sub!(/\$\{([^=}]+)/, '')
      switch_to_value_hash["${#{$1}}"] = []
    end
    return switch_to_value_hash
  end
  
  def post_process(value, space_char, no_url_encoding)
    value = CGI.escape(value) if not no_url_encoding
    value.gsub!('+', space_char)
    return value
  end
  
end