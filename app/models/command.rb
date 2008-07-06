class Command < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :url

  attr_accessible :name, :description, :url

  # find latest 
  named_scope :recent, :order => "created_at DESC"

  # find most recently used
  named_scope :most_used, :order => "uses DESC"

  # find golden eggs only
  named_scope :golden_eggs, :conditions => "golden_egg_date is not null"
    
  # handle searching
  named_scope :search, lambda { |args|
    {:conditions => Command.where(args), :order => "created_at DESC"}
  }


  def display_url
    Command.display_url_proper url
  end
  
  def self.display_url_proper(url)
    # Handle both the old and new formats [Jon Aquino 2006-04-01]
    url = url =~ /^\{url (.*)\}$/ ? $1 : url
    url = url =~ /^\{url\[no url encoding\] (.*)\}$/ ? $1 : url
  end
  
  def to_s
    self.name
  end
  
  def self.by_name(name)
    Command.find(:first, :conditions => ['name = ?', name], :order => "created_at")
  end
    
  protected
  def self.where(args)
    where = ""
    unless args.blank?
      pattern = "%#{args.strip}%"
      where = ["name like ? or description like ? or url like ?", pattern, pattern, pattern]
    end
    return where
  end
  
end
