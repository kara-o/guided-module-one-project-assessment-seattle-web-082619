require_relative '../config/environment.rb'

class RecipeBoxCLI

  RECIPE_API = 'http://www.recipepuppy.com/api/'

  @@recipe_list_array = []

  @@url = nil

  @@this_user = nil

  def self.welcome
    puts `clear`
    puts "Welcome to Recipe Box!"
    puts "What is your first name?"
    first_name = STDIN.gets.chomp.downcase
    puts "What is your last name?"
    last_name = STDIN.gets.chomp.downcase

    if User.all.select{|user| user.full_name == first_name + " " + last_name}.length == 0
      @@this_user = User.create(first_name: first_name, last_name: last_name)
      puts "Yay, I'm so glad you decided to join!  Your account has been created.  Get ready to cook!"
      new_box = RecipesBox.create
      new_box.user_id = this_user.id
      new_box.save
      self.options

    else
      @@this_user = User.all.select{user.full_name == first_name + " " + last_name}
      puts "Welcome back!  You must be hungry!"
      self.options

    end
  end

  def self.options
    is_running = true

    while is_running
      puts "What would you like to do?  Here are your options, please enter a number: "
      puts "1. Search for a recipe by ingredient"
      puts "2. Search for a recipe by title or keyword"
      puts "3. View my recipe box"
      puts "4. View my shopping list"
      puts "5. Exit"

     choice = STDIN.gets.chomp
     if choice == "1"
       self.recipe_search_by_ingredient

     elsif choice == "2"
       self.recipe_search_by_name

     elsif choice == "3"

     elsif choice == "4"

     elsif choice == "5"
       puts "Goodbye!"
       is_running = false
     else
       puts "Try again."
     end
   end
  end

  def self.recipe_search_by_ingredient
    puts "Tell me your ingredient: "
    answer = STDIN.gets.chomp.downcase
    @@url = RECIPE_API + "?i=#{answer}"
    json = get_json(@@url)
    #recipe_list = json["results"].each {|x| puts x["title"]}
    json["results"].each_with_index {|hash, index|
      indexed_item = "#{index + 1}. #{hash["title"].strip}" #delete("\n")
      puts indexed_item
      @@recipe_list_array << indexed_item
    }

    self.select_recipe
  end

  def self.recipe_search_by_name
    puts "What keyword or title should I search for?"
    answer = STDIN.gets.chomp.downcase
    @@url = RECIPE_API + "?q=#{answer}"
    json = get_json(@@url)
    json["results"].each_with_index {|hash, index|
      indexed_item = "#{index + 1}. #{hash["title"].strip}" #delete("\n")
      puts indexed_item
      @@recipe_list_array << indexed_item
    }

    self.select_recipe
  end

  def self.select_recipe
    i = 1
    more = true
    answer1 = nil
    json = get_json(@@url)
    while more == true do
      puts "Type the number of the recipe you want to view, or, type 'more' to see more recipes:"
      answer1 = STDIN.gets.chomp
      if answer1 == "more"
        i += 1
        url = @@url + "&p=#{i}"
        json = get_json(url)
        length = @@recipe_list_array.length
        json["results"].each_with_index {|hash, index|
          indexed_item = "#{index + 1 + length}. #{hash["title"].strip}"
          puts indexed_item
          @@recipe_list_array << indexed_item
        }
      else
        more = false
      end
    end

    recipe_w_index = @@recipe_list_array.find{|recipe| recipe.include?(answer1)}

    recipe = recipe_w_index[answer1.length + 2..recipe_w_index.length - 1]


    json["results"].each do |hash|
      hash.each do |k, v|
        if v.include?(recipe)
          Recipe.create("title": v, "url": hash["href"])
        end
      end
    end

    self.recipe_box_or_no

    end

    def self.recipe_box_or_no

      puts "Would you like to add this recipe to your recipe box? (Y/N)"
      answer = STDIN.gets.chomp.downcase
      is_running = true
      while is_running == true
      if answer == "y"
        my_box = RecipesBox.find_by(user_id: @@this_user.id)
        my_box.recipe_id = Recipe.last.id

      elsif answer == "n"
        is_running = false
        self.options

      else
       puts "Please enter a valid response - Y/N"
      end

end


  # if answer1 == 'more'
  #   while more == true do
  #   i += 1
    # url = @@url + "&p=#{i}"
    # json = get_json(url)
    # length = @@recipe_list_array.length
    # json["results"].each_with_index {|hash, index|
    #   indexed_item = "#{index + 1 + length}. #{hash["title"].delete("\n")}"
    #   puts indexed_item
    #   @@recipe_list_array << indexed_item
    # }
  #   puts "Do you want to see more? (Y/N)"
  #     answer2 = STDIN.gets.chomp
  #     if answer2 == "Y"
  #       more = true
  #     elsif answer2 == "N"
  #       more = false
  #       puts "Type the number of the recipe you want to view:"
  #       answer1 = STDIN.gets.chomp
  #     end
  #   end
  #
  # else
  #    answer1 = STDIN.gets.chomp
  # end



end
