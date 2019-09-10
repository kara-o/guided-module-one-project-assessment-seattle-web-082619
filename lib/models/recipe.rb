class Recipe < ActiveRecord::Base

  has_and_belongs_to_many :recipe_boxes
  has_and_belongs_to_many :ingredients 

end
