class User < ActiveRecord::Base

  has_many :recipes
  has_many :ingredient_items, through: :recipes

  def full_name
    self.first_name + " " + self.last_name
  end

end
