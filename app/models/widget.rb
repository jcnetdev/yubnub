class Widget < ActiveRecord::Base
  validates_presence_of :name, :price, :description
    
end
