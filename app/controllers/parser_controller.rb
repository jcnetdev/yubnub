class ParserController < ApplicationController
  
  def landing
  end
  
  def parse
    @command = params[:cmd] || params[:command]
    
    # check if theres a command to process
    if @command.blank?
      flash[:notice] = "No command entered."
      redirect_to root_url
      return
    end
    
    # build parser
    @parser = Parser.new(@command)
    
    # parse command
    @parser.parse(params[:default] || AppConfig.default_command)
    
    # Process
    if @parser.url.blank?
      flash[:notice] = "Unable to find a command for: <strong>#{@parser.command_name}</strong>."
      redirect_to root_url
    else
      # redirect if found
      redirect_to @parser.url
    end
  end
  
  def url
    render :text => Parser.get_url(params[:cmd])
  end
  
  def uptime
    Command.first
    render :text => "success"
  end
end
