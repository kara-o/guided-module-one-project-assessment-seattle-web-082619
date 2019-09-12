class Ingredient < ActiveRecord::Base

  has_many :shopping_list_items
  has_many :users, through: :shopping_list_items
  has_many :ingredients_recipes
  has_many :recipes, through: :ingredients_recipes

end
