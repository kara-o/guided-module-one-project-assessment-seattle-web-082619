class User < ActiveRecord::Base

  has_many :recipes_box
  has_many :recipes, through: :recipes_box

  def full_name
    self.first_name + " " + self.last_name
  end

end
