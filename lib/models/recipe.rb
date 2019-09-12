class Recipe < ActiveRecord::Base

  has_many :ingredient_items
  belongs_to :user

end
