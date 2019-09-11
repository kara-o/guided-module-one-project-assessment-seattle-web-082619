class AddIsCompleteToIngredientItems < ActiveRecord::Migration[5.2]

  def change
    add_column :ingredient_items, :is_complete, :boolean
  end

end
