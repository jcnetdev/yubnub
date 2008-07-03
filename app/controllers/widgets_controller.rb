class WidgetsController < ApplicationController
  
  before_filter :get_widget, :only => [:edit, :update, :show, :delete]
  
  def index
    @widgets = Widget.find :all
  end

  def new
    @widget = Widget.new
  end

  def create
    @widget = Widget.new(params[:widget])
    if @widget.save
      flash[:notice] = "Widget has been created."
      redirect_to widgets_url
    else
      render :action => "new"
    end
  end

  def edit
  end
  
  def update
    if @widget.update_attributes(params[:widget])
      flash[:notice] = "Widget has been updated."
      redirect_to widgets_url
    else
      render :action => "edit"
    end
  end
  
  private
  def get_widget
    @widget = Widget.find(params[:id])
  end
  
end
