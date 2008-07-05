# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # display flash_boxes (unless its already been shown)
  def flash_boxes
    unless @flash_shown
      @flash_shown = true
      render :partial => "layouts/flash_boxes"
    else
      ""
    end
  end
  
  def clear(direction = nil)
    "<div class=\"clear#{direction}\"></div>"
  end
  
  # returns the controller & action
  def action_path
    "#{params[:controller]}/#{params[:action]}"
  end
  
  # return the css class for the current controller and action
  def body_class
    classes = ""
    classes << "container"
    classes << " "
    classes << controller.controller_name
    classes << "-"
    classes << controller.action_name
    classes << " "
    unless production? 
      classes << "debug" 
    end
    
    return classes.strip
  end
  
  def production?
    ENV["RAILS_ENV"] == "production"
  end
  
  # returns either the new_arg or the edit_arg depending on if the action is a new or edit action
  def new_or_edit(new_arg, edit_arg, other = nil)
    if is_new?
      return new_arg
    elsif is_edit?
      return edit_arg
    else
      return other
    end
  end
  
  def is_new?
    action = params[:action]
    action == "new" || action == "create"
  end
      
  def is_edit?
    action = params[:action]
    action == "edit" || action == "update"
  end
  
  # Whether or not to use caching
  def use_cache?
    ActionController::Base.perform_caching
  end
  
  def paging(page_data, style = :sabros)
    return unless page_data.class == WillPaginate::Collection    
    will_paginate(page_data, :class => "pagination #{style}", :inner_window => 3)
  end
  
  def error_messages_for(name, options = {})
    super(name, {:id => "error_explanation", :class => "error"}.merge(options))
  end
  
  def hide_if(condition)
    if condition
      {:style => "display:none"}
    else
      {}
    end
  end
  
  def hide_unless(condition)
    hide_if(!condition)
  end
  
  def br
    "<br />"
  end

  def hr
    "<hr />"
  end

  def space
    "<hr class='space' />"
  end

  def anchor(anchor_name)
    "<a name='#{anchor_name}'></a>"
  end

  def button(text, options = {})
    submit_tag(text, options)
  end

  def clear_tag(tag, direction = nil)
    "<#{tag} class=\"clear#{direction}\"></#{tag}>"
  end

  def clear(direction = nil)
    clear_tag(:div, direction)
  end
  
  def lorem
    "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  end
  
  def hidden
    {:style => "display:none"}
  end
  
  def clearbit_icon(icon, color, options = {})
    image_tag "clearbits/#{icon}.gif", {:class => "clearbits #{color}", :alt => icon}.merge(options)
  end
  
  def delete_link(*args)
    options = {:method => :delete, :confirm => "Are you sure you want to delete this?"}.merge(args.extract_options!)
    args << options
    link_to *args
  end
  
  def link_to_block(*args, &block)
    content = capture_haml(&block)
    return link_to(content, *args)
  end
  
  # pixel spacing helper
  def pixel(options = {})
    image_tag "pixel.png", options
  end
end
