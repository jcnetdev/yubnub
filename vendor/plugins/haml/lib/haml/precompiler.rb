require 'strscan'

module Haml
  module Precompiler
    # Designates an XHTML/XML element.
    ELEMENT         = ?%

    # Designates a <tt><div></tt> element with the given class.
    DIV_CLASS       = ?.

    # Designates a <tt><div></tt> element with the given id.
    DIV_ID          = ?#

    # Designates an XHTML/XML comment.
    COMMENT         = ?/

    # Designates an XHTML doctype.
    DOCTYPE         = ?!

    # Designates script, the result of which is output.
    SCRIPT          = ?=

    # Designates script, the result of which is flattened and output.
    FLAT_SCRIPT     = ?~

    # Designates script which is run but not output.
    SILENT_SCRIPT   = ?-

    # When following SILENT_SCRIPT, designates a comment that is not output.
    SILENT_COMMENT  = ?#

    # Designates a non-parsed line.
    ESCAPE          = ?\\

    # Designates a block of filtered text.
    FILTER          = ?:

    # Designates a non-parsed line. Not actually a character.
    PLAIN_TEXT      = -1

    # Keeps track of the ASCII values of the characters that begin a
    # specially-interpreted line.
    SPECIAL_CHARACTERS   = [
      ELEMENT,
      DIV_CLASS,
      DIV_ID,
      COMMENT,
      DOCTYPE,
      SCRIPT,
      FLAT_SCRIPT,
      SILENT_SCRIPT,
      ESCAPE,
      FILTER
    ]

    # The value of the character that designates that a line is part
    # of a multiline string.
    MULTILINE_CHAR_VALUE = ?|

    # Characters that designate that a multiline string may be about
    # to begin.
    MULTILINE_STARTERS   = SPECIAL_CHARACTERS - [?/]

    # Keywords that appear in the middle of a Ruby block with lowered
    # indentation. If a block has been started using indentation,
    # lowering the indentation  with one of these won't end the block.
    # For example:
    #
    #   - if foo
    #     %p yes!
    #   - else
    #     %p no!
    #
    # The block is ended after <tt>%p no!</tt>, because <tt>else</tt>
    # is a member of this array.
    MID_BLOCK_KEYWORDS   = ['else', 'elsif', 'rescue', 'ensure', 'when']

    # The Regex that matches an HTML comment command.
    COMMENT_REGEX = /\/(\[[\w\s\.]*\])?(.*)/

    # The Regex that matches a Doctype command.
    DOCTYPE_REGEX = /(\d\.\d)?[\s]*([a-z]*)/i

    # The Regex that matches an HTML tag command.
    TAG_REGEX = /[%]([-:\w]+)([-\w\.\#]*)(\{.*\})?(\[.*\])?([=\/\~]?)?(.*)?/

    # The Regex that matches a literal string or symbol value
    LITERAL_VALUE_REGEX = /^\s*(:(\w*)|(('|")([^\\\#'"]*?)\4))\s*$/

    private

    # Returns the precompiled string with the preamble and postamble
    def precompiled_with_ambles(local_names)
      preamble = <<END.gsub("\n", ";")
extend Haml::Helpers
@haml_stack ||= Array.new
@haml_stack.push(Haml::Buffer.new(#{options_for_buffer.inspect}))
@haml_is_haml = true
_hamlout = @haml_stack[-1]
_erbout = _hamlout.buffer
END
      postamble = <<END.gsub("\n", ";")
@haml_is_haml = false
@haml_stack.pop.buffer
END
      preamble + locals_code(local_names) + @precompiled + postamble
    end

    def locals_code(names)
      names = names.keys if Hash == names

      names.map do |name|
        "#{name} = _haml_locals[#{name.to_sym.inspect}] || _haml_locals[#{name.to_s.inspect}]"
      end.join(';') + ';'
    end

    Line = Struct.new("Line", :text, :unstripped, :index, :spaces, :tabs)

    def precompile
      @precompiled = ''
      @merged_text = ''
      @tab_change  = 0

      old_line = Line.new
      (@template + "\n-#\n-#").split(/\n?\r|\r?\n/).each_with_index do |text, index|
        line = Line.new text.strip, text.lstrip.chomp, index
        line.spaces, line.tabs = count_soft_tabs(text)

        if line.text.empty?
          process_indent(old_line) unless !flat? || old_line.text.empty?

          unless flat?
            newline
            next
          end

          push_flat(old_line)
          old_line.text, old_line.unstripped, old_line.spaces = '', '', 0
          newline
          next
        end

        suppress_render = handle_multiline(old_line) unless flat?

        if old_line.text.nil? || suppress_render
          old_line = line
          newline
          next
        end

        process_indent(old_line) unless old_line.text.empty?

        if flat?
          push_flat(old_line)
          old_line = line
          newline
          next
        end

        if old_line.spaces != old_line.tabs * 2
          raise SyntaxError.new("Illegal Indentation: Only two space characters are allowed as tabulation.")
        end

        unless old_line.text.empty? || @haml_comment
          process_line(old_line.text, old_line.index, line.tabs > old_line.tabs && !line.text.empty?)
        end

        if !flat? && line.tabs - old_line.tabs > 1
          raise SyntaxError.new("Illegal Indentation: Indenting more than once per line is illegal.")
        end
        old_line = line
        newline
      end

      # Close all the open tags
      close until @to_close_stack.empty?
      flush_merged_text
    end
        
    # Processes and deals with lowering indentation.
    def process_indent(line)
      return unless line.tabs <= @template_tabs && @template_tabs > 0

      to_close = @template_tabs - line.tabs
      to_close.times { |i| close unless to_close - 1 - i == 0 && mid_block_keyword?(line.text) }
    end

    # Processes a single line of Haml.
    #
    # This method doesn't return anything; it simply processes the line and
    # adds the appropriate code to <tt>@precompiled</tt>.
    def process_line(text, index, block_opened)
      @block_opened = block_opened
      @index = index + 1

      case text[0]
      when DIV_CLASS, DIV_ID; render_div(text)
      when ELEMENT; render_tag(text)
      when COMMENT; render_comment(text)
      when SCRIPT
        return push_script(unescape_interpolation(text[2..-1].strip), false) if text[1] == SCRIPT
        push_script(text[1..-1], false)
      when FLAT_SCRIPT; push_flat_script(text[1..-1])
      when SILENT_SCRIPT
        return start_haml_comment if text[1] == SILENT_COMMENT

        push_silent(text[1..-1], true)
        newline true
        if (@block_opened && !mid_block_keyword?(text)) || text[1..-1].split(' ', 2)[0] == "case"
          push_and_tabulate([:script])
        end
      when FILTER; start_filtered(text[1..-1].downcase)
      when DOCTYPE
        return render_doctype(text) if text[0...3] == '!!!'
        push_plain text
      when ESCAPE; push_plain text[1..-1]
      else push_plain text
      end
    end
    
    # Returns whether or not the text is a silent script text with one
    # of Ruby's mid-block keywords.
    def mid_block_keyword?(text)
      text.length > 2 && text[0] == SILENT_SCRIPT && MID_BLOCK_KEYWORDS.include?(text[1..-1].split[0])
    end

    # Deals with all the logic of figuring out whether a given line is
    # the beginning, continuation, or end of a multiline sequence.
    #
    # This returns whether or not the line should be
    # rendered normally.
    def handle_multiline(line)
      text = line.text

      # A multiline string is active, and is being continued
      if is_multiline?(text) && @multiline
        @multiline.text << text[0...-1]
        return true
      end
      
      # A multiline string has just been activated, start adding the lines
      if is_multiline?(text) && (MULTILINE_STARTERS.include? text[0])
        @multiline = Line.new text[0...-1], nil, line.index, nil, line.tabs
        process_indent(line)
        return true
      end

      # A multiline string has just ended, make line into the result
      if @multiline && !line.text.empty?
        process_line(@multiline.text, @multiline.index, line.tabs > @multiline.tabs)
        @multiline = nil
      end

      return false
    end

    # Checks whether or not +line+ is in a multiline sequence.
    def is_multiline?(text)
      text && text.length > 1 && text[-1] == MULTILINE_CHAR_VALUE && text[-2] == ?\s
    end

    # Evaluates <tt>text</tt> in the context of the scope object, but
    # does not output the result.
    def push_silent(text, can_suppress = false)
      flush_merged_text      
      return if can_suppress && options[:suppress_eval]
      @precompiled << "#{text};"
    end

    # Adds <tt>text</tt> to <tt>@buffer</tt> with appropriate tabulation
    # without parsing it.
    def push_merged_text(text, tab_change = 0, try_one_liner = false)
      @merged_text  << "#{'  ' * @output_tabs}#{text}"
      @tab_change   += tab_change
      @try_one_liner = try_one_liner
    end
    
    def push_text(text, tab_change = 0, try_one_liner = false)
      push_merged_text("#{text}\n", tab_change, try_one_liner)
    end
    
    def flush_merged_text
      return if @merged_text.empty?

      @precompiled  << "_hamlout.push_text(#{@merged_text.dump}"
      @precompiled  << ", #{@tab_change}" if @tab_change != 0 || @try_one_liner
      @precompiled  << ");"
      @merged_text   = ''
      @tab_change    = 0
      @try_one_liner = false
    end  

    # Renders a block of text as plain text.
    # Also checks for an illegally opened block.
    def push_plain(text)
      raise SyntaxError.new("Illegal Nesting: Nesting within plain text is illegal.") if @block_opened
      push_text text
    end

    # Adds +text+ to <tt>@buffer</tt> while flattening text.
    def push_flat(line)
      tabulation = line.spaces - @flat_spaces
      tabulation = tabulation > -1 ? tabulation : 0
      @filter_buffer << "#{' ' * tabulation}#{line.unstripped}\n"
    end

    # Causes <tt>text</tt> to be evaluated in the context of
    # the scope object and the result to be added to <tt>@buffer</tt>.
    #
    # If <tt>flattened</tt> is true, Haml::Helpers#find_and_flatten is run on
    # the result before it is added to <tt>@buffer</tt>
    def push_script(text, flattened, close_tag = nil)
      flush_merged_text
      return if options[:suppress_eval]

      push_silent "haml_temp = #{text}"
      newline true
      out = "haml_temp = _hamlout.push_script(haml_temp, #{flattened.inspect}, #{close_tag.inspect});"
      if @block_opened
        push_and_tabulate([:loud, out])
      else
        @precompiled << out
      end
    end
    
    # Causes <tt>text</tt> to be evaluated, and Haml::Helpers#find_and_flatten
    # to be run on it afterwards.
    def push_flat_script(text)
      flush_merged_text
      
      raise SyntaxError.new("Tag has no content.") if text.empty?
      push_script(text, true)
    end

    def start_haml_comment
      return unless @block_opened

      @haml_comment = true
      push_and_tabulate([:haml_comment])
    end

    # Closes the most recent item in <tt>@to_close_stack</tt>.
    def close
      tag, value = @to_close_stack.pop
      case tag
      when :script; close_block
      when :comment; close_comment value
      when :element; close_tag value
      when :loud; close_loud value
      when :filtered; close_filtered value
      when :haml_comment; close_haml_comment
      end
    end

    # Puts a line in <tt>@precompiled</tt> that will add the closing tag of
    # the most recently opened tag.
    def close_tag(tag)
      @output_tabs -= 1
      @template_tabs -= 1
      push_text("</#{tag}>", -1)
    end

    # Closes a Ruby block.
    def close_block
      push_silent "end", true
      @template_tabs -= 1
    end

    # Closes a comment.
    def close_comment(has_conditional)
      @output_tabs -= 1
      @template_tabs -= 1
      close_tag = has_conditional ? "<![endif]-->" : "-->"
      push_text(close_tag, -1)
    end
    
    # Closes a loud Ruby block.
    def close_loud(command)
      push_silent 'end', true
      @precompiled << command
      @template_tabs -= 1
    end

    # Closes a filtered block.
    def close_filtered(filter)
      @flat_spaces = -1
      filtered = filter.new(@filter_buffer).render

      if filter == Haml::Filters::Preserve
        push_silent("_hamlout.buffer << #{filtered.dump} << \"\\n\";")
      else
        push_text(filtered.rstrip.gsub("\n", "\n#{'  ' * @output_tabs}"))
      end

      @filter_buffer = nil
      @template_tabs -= 1
    end

    def close_haml_comment
      @haml_comment = false
      @template_tabs -= 1
    end
    
    # Iterates through the classes and ids supplied through <tt>.</tt>
    # and <tt>#</tt> syntax, and returns a hash with them as attributes,
    # that can then be merged with another attributes hash.
    def parse_class_and_id(list)
      attributes = {}
      list.scan(/([#.])([-_a-zA-Z0-9]+)/) do |type, property|
        case type
        when '.'
          if attributes['class']
            attributes['class'] += " "
          else
            attributes['class'] = ""
          end
          attributes['class'] += property
        when '#'; attributes['id'] = property
        end
      end
      attributes
    end

    def parse_literal_value(text)
      return nil unless text
      text.match(LITERAL_VALUE_REGEX)

      # $2 holds the value matched by a symbol, but is nil for a string match
      # $5 holds the value matched by a string
      $2 || $5
    end
    
    def parse_static_hash(text)  
      return {} unless text

      attributes = {}
      text.split(',').each do |attrib|
        key, value, more = attrib.split('=>')

        # Make sure the key and value and only the key and value exist
        # Otherwise, it's too complicated or dynamic and we'll defer it to the actual Ruby parser
        key = parse_literal_value key
        value = parse_literal_value value
        return nil if more || key.nil? || value.nil?

        attributes[key] = value
      end
      attributes
    end

    # This is a class method so it can be accessed from Buffer.
    def self.build_attributes(attr_wrapper, attributes = {})
      quote_escape = attr_wrapper == '"' ? "&quot;" : "&apos;"
      other_quote_char = attr_wrapper == '"' ? "'" : '"'
  
      result = attributes.collect do |attr, value|
        next if value.nil?

        value = value.to_s
        this_attr_wrapper = attr_wrapper
        if value.include? attr_wrapper
          if value.include? other_quote_char
            value = value.gsub(attr_wrapper, quote_escape)
          else
            this_attr_wrapper = other_quote_char
          end
        end
        " #{attr}=#{this_attr_wrapper}#{value}#{this_attr_wrapper}"
      end
      result.compact.sort.join
    end

    def prerender_tag(name, atomic, attributes)
      "<#{name}#{Precompiler.build_attributes(@options[:attr_wrapper], attributes)}#{atomic ? ' />' : '>'}"
    end

    # Parses a line that will render as an XHTML tag, and adds the code that will
    # render that tag to <tt>@precompiled</tt>.
    def render_tag(line)
      raise SyntaxError.new("Invalid tag: \"#{line}\"") unless match = line.scan(TAG_REGEX)[0]
      tag_name, attributes, attributes_hash, object_ref, action, value = match
      value = value.to_s.strip
      attributes_hash = attributes_hash[1...-1] if attributes_hash

      raise SyntaxError.new("Illegal element: classes and ids must have values.") if attributes =~ /[\.#](\.|#|\z)/

      case action
      when '/'; atomic = true
      when '~'; parse = flattened = true
      when '='
        parse = true
        value = unescape_interpolation(value[1..-1].strip) if value[0] == ?=
      end
        
      if parse && @options[:suppress_eval]
        parse = false
        value = ''
      end

      object_ref = "nil" if object_ref.nil? || @options[:suppress_eval]

      static_attributes = parse_static_hash(attributes_hash) # Try pre-compiling a static attributes hash
      attributes_hash = nil if static_attributes || @options[:suppress_eval]
      attributes = parse_class_and_id(attributes)
      Buffer.merge_attrs(attributes, static_attributes) if static_attributes

      raise SyntaxError.new("Illegal Nesting: Nesting within an atomic tag is illegal.") if @block_opened && atomic
      raise SyntaxError.new("Illegal Nesting: Nesting within a tag that already has content is illegal.") if @block_opened && !value.empty?
      raise SyntaxError.new("Tag has no content.") if parse && value.empty?
      raise SyntaxError.new("Atomic tags can't have content.") if atomic && !value.empty?

      atomic = true if !@block_opened && value.empty? && @options[:autoclose].include?(tag_name)
      
      if object_ref == "nil" && attributes_hash.nil? && !flattened && (parse || Buffer.one_liner?(value))
        # This means that we can render the tag directly to text and not process it in the buffer
        tag_closed = !value.empty? && Buffer.one_liner?(value) && !parse

        open_tag  = prerender_tag(tag_name, atomic, attributes)
        open_tag << "#{value}</#{tag_name}>" if tag_closed
        open_tag << "\n" unless parse

        push_merged_text(open_tag, tag_closed || atomic ? 0 : 1, parse)
        return if tag_closed
      else
        flush_merged_text
        content = value.empty? || parse ? 'nil' : value.dump
        attributes_hash = ', ' + attributes_hash if attributes_hash
        push_silent "_hamlout.open_tag(#{tag_name.inspect}, #{atomic.inspect}, #{(!value.empty?).inspect}, #{attributes.inspect}, #{object_ref}, #{content}#{attributes_hash})"
      end
          
      return if atomic

      if value.empty?
        push_and_tabulate([:element, tag_name])
        @output_tabs += 1
        return
      end
      
      if parse
        flush_merged_text
        push_script(value, flattened, tag_name)
      end
    end

    # Renders a line that creates an XHTML tag and has an implicit div because of
    # <tt>.</tt> or <tt>#</tt>.
    def render_div(line)
      render_tag('%div' + line)
    end

    # Renders an XHTML comment.
    def render_comment(line)
      conditional, content = line.scan(COMMENT_REGEX)[0]
      content.strip!
      conditional << ">" if conditional
      
      if @block_opened && !content.empty?
        raise SyntaxError.new('Illegal Nesting: Nesting within a tag that already has content is illegal.')
      end

      open = "<!--#{conditional} "
      
      # Render it statically if possible
      if !content.empty? && Buffer.one_liner?(content)
        return push_text("#{open}#{content} #{conditional ? "<![endif]-->" : "-->"}")
      end

      push_text(open, 1)
      @output_tabs += 1
      push_and_tabulate([:comment, !conditional.nil?])
      unless content.empty?
        push_text(content)
        close
      end
    end
    
    # Renders an XHTML doctype or XML shebang.
    def render_doctype(line)
      raise SyntaxError.new("Illegal Nesting: Nesting within a header command is illegal.") if @block_opened
      push_text text_for_doctype(line)
    end

    def text_for_doctype(text)
      text = text[3..-1].lstrip.downcase
      if text[0...3] == "xml"
        wrapper = @options[:attr_wrapper]
        return "<?xml version=#{wrapper}1.0#{wrapper} encoding=#{wrapper}#{text.split(' ')[1] || "utf-8"}#{wrapper} ?>"
      end

      version, type = text.scan(DOCTYPE_REGEX)[0]
      if version == "1.1"
        return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
      end

      case type
      when "strict";   return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
      when "frameset"; return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
      else             return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
      end
    end

    # Starts a filtered block.
    def start_filtered(name)
      raise SyntaxError.new('Filters must have nested text.') unless @block_opened

      unless filter = options[:filters][name]
        if filter == 'redcloth' || filter == 'markdown' || filter == 'textile'
          raise HamlError.new("You must have the RedCloth gem installed to use \"#{name}\" filter")
        end
        raise HamlError.new("\"#{name}\" filter is not defined!")
      end

      push_and_tabulate([:filtered, filter])
      @flat_spaces = @template_tabs * 2
      @filter_buffer = String.new
    end

    def unescape_interpolation(str)
      scan = StringScanner.new(str.dump)
      str = ''

      while scan.scan(/(.*?)\\\#\{/)
        str << scan.matched[0...-3]
        str << eval("\"\\\#{#{balance_brackets(scan)}}\"")
      end

      str + scan.rest
    end

    def balance_brackets(scanner)
      str = ''
      count = 1

      while scanner.scan(/(.*?)[\{\}]/)
        str << scanner.matched
        count += 1 if scanner.matched[-1] == ?{
        count -= 1 if scanner.matched[-1] == ?}
        return str[0...-1] if count == 0
      end

      raise SyntaxError.new("Unbalanced brackets.")
    end

    # Counts the tabulation of a line.
    def count_soft_tabs(line)
      spaces = line.index(/([^ ]|$)/)
      if line[spaces] == ?\t
        return nil if line.strip.empty?
        raise SyntaxError.new("Illegal Indentation: Only two space characters are allowed as tabulation.")
      end
      [spaces, spaces/2]
    end
    
    # Pushes value onto <tt>@to_close_stack</tt> and increases
    # <tt>@template_tabs</tt>.
    def push_and_tabulate(value)
      @to_close_stack.push(value)
      @template_tabs += 1
    end

    def flat?
      @flat_spaces != -1
    end

    def newline(skip_next = false)
      return @skip_next_newline = false if @skip_next_newline
      @skip_next_newline = true if skip_next
      @precompiled << "\n"
    end
  end
end
