Recipe.destroy_all
IngredientItem.destroy_all
User.destroy_all


10.times do
User.create(first_name: Faker::Name.first_name.downcase, last_name: Faker::Name.last_name.downcase)
Recipe.create(title: Faker::Food.dish, ingredients: Faker::Food.ingredient, url: Faker::Internet.url(host: 'simplyrecipes.com', path:'/recipes/classic_baked_acorn_squash/'), user_id: User.all.sample.id)
IngredientItem.create(name: Faker::Food.ingredient, is_complete: false, recipe_id: Recipe.all.sample.id)
end
