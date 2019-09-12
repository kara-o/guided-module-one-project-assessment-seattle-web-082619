class CreateInitialTables < ActiveRecord::Migration[5.2]

  def change

    create_table :users do |t|
      t.string :first_name
      t.string :last_name
    end

    create_table :recipes_users do |t|
      t.integer :user_id
      t.integer :recipe_id
    end

    create_table :recipes do |t|
      t.string :title
      t.string :url
    end

    create_table :ingredients_recipes do |t|
      t.integer :ingredient_id
      t.integer :recipe_id
    end

    create_table :ingredients do |t|
      t.string :name
    end

    create_table :shopping_list_items do |t|
      t.string :user_id
      t.string :ingredient_id
      t.boolean :is_complete
    end

  end

end
