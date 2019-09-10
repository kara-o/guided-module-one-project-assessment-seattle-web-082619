class User < ActiveRecord::Base

  has_one :recipe_box

  def full_name
    self.first_name + " " + self.last_name
  end

end
