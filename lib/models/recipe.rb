class Recipe < ActiveRecord::Base

  has_many :recipes_box
  has_many :users, through: :recipes_box
  has_many :ingredient_items

end
