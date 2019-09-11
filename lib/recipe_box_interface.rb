require_relative '../config/environment.rb'

class RecipeBoxCLI

  RECIPE_API = 'http://www.recipepuppy.com/api/'

  # @@recipe_list_array = []
  #
  # @@url = nil
  #
  # @@this_user = nil

  def self.welcome
    puts `clear`
    puts ''
    puts ''
    puts "Welcome to Recipe Box!"
    puts ''
    puts ''
    puts "What is your first name?"
    first_name = STDIN.gets.strip.downcase
    puts "What is your last name?"
    last_name = STDIN.gets.strip.downcase

    if !User.find_by(first_name: first_name, last_name: last_name)
      this_user = User.create(first_name: first_name, last_name: last_name)
      puts ''
      puts "Yay, I'm so glad you decided to join!  Your account has been created.  Get ready to cook!"
      puts ''
      self.options(this_user)

    else
      this_user = User.find_by(first_name: first_name, last_name: last_name)
      puts ''
      puts "Welcome back!  You must be hungry!"
      puts ''
      self.options(this_user)
    end
  end

  def self.options(this_user)
    is_running = true

    while is_running
      puts "What would you like to do?  Here are your options, please enter a number: "
      puts "1. Search for a recipe by ingredient"
      puts "2. Search for a recipe by title or keyword"
      puts "3. View my recipe box"
      puts "4. View my shopping list"
      puts "5. Exit"

     input = STDIN.gets.chomp
     if choice == "1"
       self.recipe_search_by_ingredient

     elsif choice == "2"
       self.recipe_search_by_name

     elsif choice == "3"
       my_recipes = @@this_user.recipes
       if my_recipes.length == 0
         puts "Empty!!! Looks like you need to find some recipes first!"
       else
         my_recipes.each_with_index{|recipe, index| puts "#{index + 1}. #{recipe.title}"}
         puts "If you want to view one of your recipes please type its number, or, type 'back' to return to the menu:" #index + 1?? recipe array
         input = STDIN.gets.chomp
         if input == "back"
           self.options
         elsif (0..my_recipes.length).include?(input.to_i)
         #recipe = my_recipes.find{|recipe| recipe.title.include?(recipe.title[input.length] + 2..recipe.title.length - 1])}
           recipe = my_recipes[input.to_i - 1]
           puts `open #{recipe.url}`
           self.add_to_shopping_list(recipe.id)
         else
           puts "Please enter a valid response:"
         end
       end


     elsif choice == "4"
       self.view_shopping_list

     elsif choice == "5"
       puts "Goodbye!"
       is_running = false
     else
       puts "Please enter a valid response!"
     end
   end
  end

  def self.recipe_search_by_ingredient
    is_running = true
    while is_running == true

      puts "Tell me your ingredient: "
      answer = STDIN.gets.chomp.downcase
      @@url = RECIPE_API + "?i=#{answer}"
      json = get_json(@@url)
      if json["results"].length == 0
        puts "So sorry, but I can't find anything with that ingredient!  Please try again."
      else
        is_running = false
        json["results"].each_with_index {|hash, index|
          indexed_item = "#{index + 1}. #{hash["title"].gsub(/[^A-Z\/\-\' ]|\t\r\n\f\v/i, '')}" #delete("\n")
          puts indexed_item
          @@recipe_list_array << indexed_item
        }
      end
    end
    self.select_recipe
  end

  def self.recipe_search_by_name
    is_running = true
    while is_running == true
      puts "What keyword or title should I search for?"
      answer = STDIN.gets.chomp.downcase
      @@url = RECIPE_API + "?q=#{answer}"
      json = get_json(@@url)
      if json["results"].length == 0
        puts "So sorry, but I can't find anything with that title or keyword!  Please try again."
      else
        is_running = false
        json["results"].each_with_index {|hash, index|
          indexed_item = "#{index + 1}. #{hash["title"].gsub(/[^A-Z\/\-\' ]|\t\r\n\f\v/i, '')}" #delete("\n")
          puts indexed_item
          @@recipe_list_array << indexed_item
        }
      end
    end
    self.select_recipe
  end

  def self.select_recipe
    i = 1
    more = true
    answer1 = nil
    json = get_json(@@url)
    while more == true do
      puts "Type the number of the recipe you want to view, or, 'more' to see more recipes, or, 'back' to return to the menu: "
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
      elsif answer1 == "back"
        more = false
        self.options
      else
        more = false
      end
    end

    recipe_w_index = @@recipe_list_array.find{|recipe| recipe.include?(answer1)}  #optionally include s? if empty results, need response

    recipe = recipe_w_index[answer1.length + 2..recipe_w_index.length - 1]


    json["results"].each do |hash|
      hash.each do |k, v|
        if v.include?(recipe)
          Recipe.create("title": v, "url": hash["href"], "ingredients": hash["ingredients"])
          url = hash["href"]
          puts `open #{url}`
        end
      end
    end


    self.recipe_box_or_no

    end

    def self.recipe_box_or_no

      puts "Would you like to add this recipe to your recipe box? (Y/N)"
      answer1 = STDIN.gets.chomp.downcase
      # is_running = true
      # while is_running == true
      if answer1 == "y"
        my_box = RecipesBox.find_by(user_id: @@this_user.id)
        my_box.recipe_id = Recipe.last.id
        my_box.save
        puts "Done!  You can view your recipe box from the main menu."
        # is_running = false
        # puts "Do you want to add the ingredients for this recipe to your shopping list? (Y/N)"
        #
        # answer2 = STDIN.gets.chomp.downcase
        # if answer2 == "y"
        #   self.add_to_shopping_list
        #   # ingredient_arr = Recipe.last.ingredients.split(", ")
        #   # ingredient_arr.each do |item|
        #   #   IngredientItem.create(name: item, recipe_id: Recipe.last.id)
        #   # end
        #
        # elsif answer2 == "n"
        #   puts "Wow you must have a good memory!"
        #
        # else
        #   puts "Please enter a valid response - Y/N:"
        # end

        self.add_to_shopping_list(Recipe.last.id)

      elsif answer1 == "n"
        puts "Okay, well let's look for a better recipe!"

      else
        puts "Please enter a valid response - Y/N:"
      end

    end


    def self.add_to_shopping_list(id)
      puts "Do you want to add the ingredients for this recipe to your shopping list? (Y/N)"

      answer = STDIN.gets.chomp.downcase
      if answer == "y"
        ingredient_arr = Recipe.find(id).ingredients.split(", ")
        ingredient_arr.each do |item|
            IngredientItem.create(name: item, recipe_id: Recipe.find(id).id, is_complete: false)
            puts "Added #{item}!"
        end

      elsif answer2 == "n"
        puts "Wow you must have a good memory!"

      else
        puts "Please enter a valid response - Y/N:"
      end

    end

    def self.my_recipes
      @@this_user.recipes
    end


    def self.view_shopping_list  #need to figure out how to take care of recipe list present but no ingredients
      binding.pry
      if @@this_user.recipes.length == 0 #|| @@this_user.ingredients.length == 0
        puts "No list at the moment, we need to find recipes!!"
      else

        self.my_recipes.each do |recipe|
          IngredientItem.where(recipe_id: recipe.id).each do |ing_item|
            if ing_item.is_complete == true
              puts "(✓) #{ing_item.name}"
            else
              puts "( ) #{ing_item.name}"
            end
          end
        end


        is_running = true

        while is_running == true
          puts "What would you like to do?  Please enter a number: "
          puts "1. Check off item on list"
          puts "2. Clear shopping list"
          puts "3. Return to menu"
          input = STDIN.gets.chomp.downcase

          if input == "1"
            self.check_off_items
          elsif input == "2"
            self.my_recipes.each do |recipe|
              IngredientItem.where(recipe_id: recipe.id).each do |ing_item|
                ing_item.destroy
              end
              puts "List cleared!"
            end
          elsif input == "3"
            is_running = false
            self.options
          else
            "Please enter a valid response!"
          end
        end
      end
    end


   def self.check_off_items
     puts "Which item can we check off your list?"
     input = STDIN.gets.chomp.downcase
     binding.pry
     self.my_recipes.each do |recipe|
       IngredientItem.where(recipe_id: recipe.id, name: input, is_complete: false).each do |ing_item|
         ing_item.update(is_complete: true)
       end
     end
     self.view_shopping_list
   end

  end
