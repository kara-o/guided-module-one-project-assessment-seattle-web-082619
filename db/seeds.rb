Recipe.destroy_all
Ingredient.destroy_all
User.destroy_all
ShoppingListItem.destroy_all
IngredientsRecipe.destroy_all
RecipesUser.destroy_all

10.times do
new_user = User.new(first_name: Faker::Name.first_name.downcase, last_name: Faker::Name.last_name.downcase)
new_recipe = Recipe.new(title: Faker::Food.dish, url: Faker::Internet.url(host: 'simplyrecipes.com', path:'/recipes/classic_baked_acorn_squash/'))
new_ingredient = Ingredient.new(name: Faker::Food.ingredient)
new_user.recipes << new_recipe
new_recipe.ingredients << new_ingredient
new_user.save
new_recipe.save
new_ingredient.save
ShoppingListItem.create(user_id: new_user.id, ingredient_id: new_ingredient.id, is_complete: false)
end
