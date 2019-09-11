class User < ActiveRecord::Base

  has_many :recipes_box
  has_many :recipes, through: :recipes_box

  def full_name
    self.first_name + " " + self.last_name
  end

  def ingredients
    ingredient_arr = []
    my_recipe_box = RecipesBox.where(user_id: self.id)
    my_recipe_box.each do |recipe|
      ingredient_arr << IngredientItem.where(recipe_id: recipe.recipe_id)
    end
    ingredient_arr
  end

end
