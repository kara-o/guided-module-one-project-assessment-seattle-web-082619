#3 classes
#call destroy on each


Recipe.destroy_all
Ingredient.destroy_all
User.destroy_all



User.create(first_name: "alex", last_name: "odle")
Recipe.create(title: "", ingredients: Faker::Food.dish, url: Faker::Internet.url(host: 'simplyrecipes.com', path:'/recipes/classic_baked_acorn_squash/'))
Ingredient.create(name: Faker::Food.ingredient, is_complete: false)
end
