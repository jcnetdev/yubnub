class KernelController < ApplicationController
  def ls    
    @commands = Command.search(params[:args]).paginate :page => params[:page]
    
    unless params[:args].blank?
      params[:cmd] = "ls #{params[:args]}"
    end

    respond_to do |format|
      format.html
      # format.xml
    end
  end

  def man
    if params['args'].blank? then
      redirect_to :action => 'man', :args => 'man'
      return      
    end
    
    @command_name = params[:args]
    @command = Command.by_name @command_name

    respond_to do |format|
      format.html do
        render(:action => :no_manual_entry) unless @command
      end
      # format.xml
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
      # format.xml
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
