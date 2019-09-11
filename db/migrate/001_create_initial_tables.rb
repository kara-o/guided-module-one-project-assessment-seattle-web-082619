class CreateInitialTables < ActiveRecord::Migration[5.2]

  def change

    create_table :users do |t|
      t.string :first_name
      t.string :last_name
    end

    create_table :recipes_boxes do |t|
      t.integer :user_id
      t.integer :recipe_id
    end

    create_table :recipes do |t|
      t.string :title
    end

    create_table :ingredients do |t|
      t.string :name
    end

  end

end
