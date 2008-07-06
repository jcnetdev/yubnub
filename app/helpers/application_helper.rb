module ApplicationHelper
  def truncate_with_ellipses(string, max_chars)
    string[0..max_chars-1] + (string.length > max_chars ? "..." : "")
  end
  
  def prefix_with_http_if_necessary(url)
    ! url_format_recognized(url) ? 'http://' + url : url
  end
  
  def prefix_with_url_if_necessary url    
    # Do not url-encode the stuff between {}, because it is not a URL.
    # See "rewriting bl, but it insists on transforming characters", 
    # http://groups.google.com/group/YubNub/browse_thread/thread/abcf3e5852268d85/fb1896ec6f341003#fb1896ec6f341003  [Jon Aquino 2006-04-01]
    (! url_format_recognized(url) and !Command.by_name(url.split[0]).nil?) ? "{url[no url encoding] #{url}}" : url
  end
  
  def url_format_recognized(url)
    url =~ /^((http)|(\{))/
  end
  
  # display flash_boxes (unless its already been shown)
  def flash_boxes
    unless @flash_shown
      @flash_shown = true
      render :partial => "layouts/flash_boxes"
    else
      ""
    end
  end

  # show paging
  def paging(page_data, style = :meneame)
    return unless page_data.is_a? WillPaginate::Collection    
    will_paginate(page_data, :class => "pagination #{style}", :inner_window => 3)
  end
  
end
