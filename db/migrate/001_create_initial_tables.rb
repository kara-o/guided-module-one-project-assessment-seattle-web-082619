class CreateInitialTables < ActiveRecord::Migration[5.2]

  def change

    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :recipe_boxes do |t|
      t.integer :user_id
      t.timestamps
    end

    create_table :recipes do |t|
      t.string :title
      t.timestamps
    end

    create_table :ingredients do |t|
      t.string :name
      t.timestamps
    end

  end

end
