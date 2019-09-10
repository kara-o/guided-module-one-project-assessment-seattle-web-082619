class AddUrlToRecipes < ActiveRecord::Migration[5.2]

  def change
    add_column :recipes, :url, :string
  end


end
