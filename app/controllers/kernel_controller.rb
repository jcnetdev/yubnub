class KernelController < ApplicationController
  def ls    
    @commands = Command.search(params[:args]).paginate :page => params[:page]
    
    unless params[:args].blank?
      params[:cmd] = "ls #{params[:args]}"
    end

    respond_to do |format|
      format.html
      format.xml do
        @feed_title = "#{AppConfig.site_name}: #{params[:cmd]}"
        @feed_description = "Listing commands with: #{params[:args]}"
        render :template => "commands/index.xml.builder"
      end
    end
  end

  def man
    if params['args'].blank? then
      redirect_to man_url(:args => 'man')
      return      
    end
    
    @command_name = params[:args]
    @command = Command.by_name @command_name

    respond_to do |format|
      format.html do
        render(:action => :no_manual_entry) unless @command
      end
      format.xml do 
        @feed_title = "#{AppConfig.site_name}: man #{@command_name}"
        @feed_description = "Usage description for: #{@command_name}"
        @commands = [@command]
        render :template => "commands/index.xml.builder"
      end
    end
  end

  def golden_eggs
    if params[:all] == "true"
      @commands = Command.golden_eggs.recent
    else
      @commands = Command.golden_eggs.search(params[:args]).paginate :page => params[:page]
    end
    
    respond_to do |format|
      format.html
      format.xml do
        @feed_title = "#{AppConfig.site_name} Golden Eggs"
        @feed_description = "Welcome to #{AppConfig.site_name} Golden Eggs! The Golden Eggs are #{AppConfig.site_name} commands that people seem to find particularly useful and interesting. If you want to nominate a #{AppConfig.site_name} command for this list, email Jon about it."
        render :template => "commands/index.xml.builder"
      end
    end
  end

  def most_used_commands
    @commands = Command.most_used.paginate :page => params[:page]
    
    respond_to do |format|
      format.html
      # format.xml
    end
  end


end
