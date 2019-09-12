class Recipe < ActiveRecord::Base

  has_many :ingredients_recipes
  has_many :ingredients, through: :ingredients_recipes
  has_many :recipes_users
  has_many :users, through: :recipes_users

end
