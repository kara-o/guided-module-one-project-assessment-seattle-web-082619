class User < ActiveRecord::Base

  has_many :shopping_list_items
  has_many :ingredients, through: :shopping_list_items
  has_many :recipes_users
  has_many :recipes, through: :recipes_users

  def full_name
    self.first_name + " " + self.last_name
  end

end
