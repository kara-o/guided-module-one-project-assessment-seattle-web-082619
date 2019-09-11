class DropThenAddTableForIngredientItems < ActiveRecord::Migration[5.2]

  def change
    drop_table :ingredients
    create_table :ingredient_items do |t|
      t.string :name
      t.integer :recipe_id
    end
  end


end
