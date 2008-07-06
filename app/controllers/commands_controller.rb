class CommandsController < ApplicationController

  def index
    @commands = Command.recent.paginate :page => params[:page]
    respond_to do |format|
      format.html
      # format.xml
    end
  end
  
  def new
    @command = Command.new(:name => params["name"].to_s)
    flash.now[:notice] = "Hmm! Looks like you're creating a new command!<br/>Good for you, buckeroo!"
  end

  def create
    @command = Command.new(params[:command])
    # Call prefix_with_url_if_necessary before prefix_with_http_if_necessary, because the latter checks
    # if the url begins with { [Jon Aquino 2005-07-17]
    url = ApplicationController.helpers.prefix_with_url_if_necessary @command.url
    url = ApplicationController.helpers.prefix_with_http_if_necessary @command.url
    
    unless @command.valid?
      flash.now[:error] = "Please fill in both name and url to create a command."
      render :action => "new"
      return
    end
      
    
    # check if we should run the test
    unless params['test_button'].blank?
      test_command @command.url, params['test_command']
      return
    end

    # check if we should run the view
    unless params['view_url_button'].blank?
      test_command @command.url, params['test_command'], true
      return
    end
    
    # check if we have a banned pattern
    if BannedUrlPattern.find(:first, :conditions => ["? LIKE pattern", @command.url]) then
      # spam [Jon Aquino 2005-06-10]
      redirect_after_add_command
      return
    end
    
    if params['x'] != '' then
      redirect_after_add_command
      return
    end
    
    # Only ban a url if it hasn't been entered earlier than an hour # ago. Otherwise clever spammers
    # will ban good url's that have been around for a long time. [Jon # Aquino 2005-06-11]
    matching_commands = Command.find(:all, :conditions => ['url = ?', @command.url], :order => 'created_at')
    if matching_commands.size >= 3 and Time.now-matching_commands[0].created_at<60*60
      # spam [Jon Aquino 2005-06-10]
      matching_commands.each { |command| command.destroy }
      pattern = BannedUrlPattern.new
      # Drop % from pattern -- it's dangerous. [Jon Aquino 2005-06-11]
      pattern.pattern = @command.url.gsub(/[%_]/, '')
      if not pattern.save then raise 'pattern.save failed' end
      redirect_after_add_command
      return
    end

    @command.save!
    
    flash[:notice] = "Successfully created command: <strong>#{@command.name}</strong>"

    redirect_after_add_command
  end
  
  def exists
    output = Command.by_name(params["name"]) ? 'true' : 'false'
    json = '({exists: ' + output + '})'
    response.headers['X-JSON'] = json
    render({:content_type => :js, :text => json})
  end
  
  def test_command(url, command_string, view = false)
    @parser = Parser.new(command_string)
    @parser.command = Command.new(:name => params[:command][:name], :url => url)
    
    if view
      render :text => @parser.parse.url
    else
      redirect_to @parser.parse.url
    end
  end
  
  def view_url
    @parser = Parser.new(command_string)
    @parser.command = Command.new(:name => params[:command][:name], :url => url)
    render :text => @parser.parse.url
  end

  protected

  def redirect_after_add_command
    # Add a space ("+") to save the user the trouble [Jon Aquino # 2005-06-04]
    # For some reason, ".html" is getting appended to the URL. This # started to happen after TextDrive moved
    # YubNub to a faster server (the "Jason Special"). Drop the # command auto-population for now.
    # [Jon Aquino 2005-06-20]
    redirect_to root_url
  end
end
