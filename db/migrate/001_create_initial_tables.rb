class CreateInitialTables < ActiveRecord::Migration[5.2]

  def change

    create_table :users do |t|
      t.string :first_name
      t.string :last_name
    end

    create_table :recipes do |t|
      t.string :title
      t.string :ingredients
      t.string :url
      t.integer :user_id
    end

    create_table :ingredients do |t|
      t.string :name
      t.boolean :is_complete
      t.integer :recipe_id
    end

  end

end
