class CreateInitialTables < ActiveRecord::Migration[5.2]


CHANGE
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
      t.integer :ingredient_id
    end

    create_table :ingredients do |t|
      t.string :name
      t.boolean :is_complete
    end

  end

end
