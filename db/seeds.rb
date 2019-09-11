#3 classes
#call destroy on each


Recipe.destroy_all
RecipesBox.destroy_all
User.destroy_all


10.times do
User.create(first_name: Faker::Name.first_name.downcase, last_name: Faker::Name.last_name.downcase)
Recipe.create(title: Faker::Food.dish, ingredients: Faker::Food.ingredient, url: Faker::Internet.url(host: 'simplyrecipes.com', path:'/recipes/classic_baked_acorn_squash/'))
end

RecipesBox.create(user_id: User.first.id, recipe_id: Recipe.first.id)
RecipesBox.create(user_id: User.last.id, recipe_id: Recipe.last.id)
RecipesBox.create(user_id: User.last.id, recipe_id: Recipe.first.id)
