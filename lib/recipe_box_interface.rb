require_relative '../config/environment.rb'

class RecipeBoxCLI

  RECIPE_API = 'http://www.recipepuppy.com/api/'

  def self.welcome
    puts `clear`
    puts ''
    puts "WELCOME TO THE RECIPE BOX APP!"
    puts ''
    puts "What is your first name?"
    puts ''
    first_name = STDIN.gets.strip.downcase
    puts ''
    puts "What is your last name?"
    puts ''
    last_name = STDIN.gets.strip.downcase

    if !User.find_by(first_name: first_name, last_name: last_name)
      this_user = User.create(first_name: first_name, last_name: last_name)
      puts ''
      puts "Hi #{this_user.first_name.capitalize}, I'm so glad you decided to join!  Your account has been created.  Get ready to cook!"
      puts ''
      puts `clear`
      self.options(this_user)

    else
      this_user = User.find_by(first_name: first_name, last_name: last_name)
      puts ''
      puts "Welcome back #{this_user.first_name.capitalize}!  You must be hungry!"
      puts ''
      puts `clear`
      self.options(this_user)
    end
  end

  def self.options(this_user)
    is_running = true

    while is_running
      puts ''
      puts "What would you like to do?  Here are your options, please enter a number: "
      puts ''
      puts "1. Search for a recipe by ingredient"
      puts ''
      puts "2. Search for a recipe by title or keyword"
      puts ''
      puts "3. View my recipe box"
      puts ''
      puts "4. View my shopping list"
      puts ''
      puts "5. Exit"
      choice = STDIN.gets.strip
      puts `clear`

     if choice == "1"
       self.recipe_search_by_ingredient(this_user)

     elsif choice == "2"
       self.recipe_search_by_word(this_user)

     elsif choice == "3"
       my_recipes = this_user.recipes
       if my_recipes.length == 0
         puts ''
         puts "Empty!!! Looks like you need to find some recipes!"
         puts ''
       else
         my_recipes.each_with_index{|recipe, index| puts "#{index + 1}. #{recipe.title}"}
         puts ''
         puts "If you want to view one of your recipes please type its number, or, type 'back' to return to the menu: "
         puts ''
         input = STDIN.gets.strip
         if input.downcase == "back"
           self.options(this_user)
         elsif (0..my_recipes.length).include?(input.to_i)
           recipe = my_recipes[input.to_i - 1]
           puts `open #{recipe.url}`
           id = recipe.id
           self.add_to_shopping_list(this_user, id)
         else
           puts ''
           puts "Please enter a valid response:"
           puts ''
         end
       end


     elsif choice == "4"
       self.view_shopping_list(this_user)

     elsif choice == "5"
       puts ''
       puts "Goodbye!"
       puts ''
       is_running = false
     else
       puts ''
       puts "Please enter a valid response!"
       puts ''
     end
   end
  end

  def self.recipe_search_by_ingredient(this_user)
    is_running = true
    while is_running == true
      puts ''
      puts "Tell me your ingredient: "
      puts ''
      answer = STDIN.gets.strip.downcase
      url = RECIPE_API + "?i=#{answer}"
      json = get_json(url)
      if json["results"].length == 0
        puts ''
        puts "So sorry, but I can't find anything with that ingredient!  Please try again."
        puts ''
      else
        is_running = false
        recipe_list_array = []
        json["results"].each_with_index {|hash, index|
          indexed_item = "#{index + 1}. #{hash["title"].gsub(/[^A-Z\/\-\' ]|\t\r\n\f\v/i, '')}"
          puts ''
          puts indexed_item
          puts ''
          recipe_list_array << indexed_item
        }
      end
    end
    self.select_recipe(this_user, url, recipe_list_array)
  end

  def self.recipe_search_by_word(this_user)
    is_running = true
    while is_running == true
      puts ''
      puts "What keyword or title should I search for?"
      puts ''
      answer = STDIN.gets.chomp.downcase
      url = RECIPE_API + "?q=#{answer}"
      json = get_json(url)
      if json["results"].length == 0
        puts ''
        puts "So sorry, but I can't find anything with that title or keyword!  Please try again."
        puts ''
      else
        is_running = false
        recipe_list_array = []
        json["results"].each_with_index {|hash, index|
          indexed_item = "#{index + 1}. #{hash["title"].gsub(/[^A-Z\/\-\' ]|\t\r\n\f\v/i, '')}"
          puts ''
          puts indexed_item
          puts ''
          recipe_list_array << indexed_item
        }
      end
    end
    self.select_recipe(this_user, url, recipe_list_array)
  end

  def self.select_recipe(this_user, url, recipe_list_array)
    i = 1
    more = true
    answer1 = nil
    json = get_json(url)
    while more == true do
      puts ''
      puts "Type the number of the recipe you want to view, or, 'more' to see more recipes, or, 'back' to return to the menu: "
      puts ''
      answer1 = STDIN.gets.strip
      puts `clear`
      if answer1.downcase == "more"
        i += 1
        url1 = url + "&p=#{i}"
        json = get_json(url1)
        length = recipe_list_array.length
        json["results"].each_with_index {|hash, index|
          indexed_item = "#{index + 1 + length}. #{hash["title"].strip}"
          puts ''
          puts indexed_item
          puts ''
          recipe_list_array << indexed_item
        }
      elsif answer1.downcase == "back"
        more = false
        puts `clear`
        self.options(this_user)
      elsif !(1..recipe_list_array.length).include?(answer1.to_i) && answer1.downcase != "more" && answer1.downcase != "back"
        puts `clear`
        puts ''
        puts "Please enter a valid response!"
        puts ''
      else
        more = false
      end
    end

    recipe_w_index = recipe_list_array.find{|recipe| recipe.include?(answer1)}
    recipe = recipe_w_index[answer1.length + 2..recipe_w_index.length - 1]


    json["results"].each do |hash|

      hash.each do |k, v|
        if v.include?(recipe)
          Recipe.create("title": v, "url": hash["href"])
          ingredients_string = hash["ingredients"]
          ingredient_array = ingredients_string.split(", ")
          ingredients_array.each do |item_string|
            Ingredient.create(name: item_string.downcase)
            Recipe.last.ingredients << Ingredient.last
            Recipe.last.save
          end
          new_recipe = Recipe.last
          url2 = hash["href"]
          puts `open #{url2}`
        end
      end
    end
    self.recipe_box_or_no(this_user, new_recipe)
    end

    def self.recipe_box_or_no(this_user, new_recipe)
      is_running = true
      while is_running == true
        puts ''
        puts "Would you like to add this recipe to your recipe box? (Y/N)"
        puts ''
        answer = STDIN.gets.strip.downcase
        puts `clear`

        if answer == "y"
          this_user.recipes << new_recipe
          this_user.save
          puts ''
          puts "Done! Great choice, #{this_user.first_name.capitalize}!"
          puts `clear`
          other_users = User.all.select{|user| user.recipes.include?(new_recipe)}
            if other_users.length > 0
              puts "Hey, this is cool!  Another user named #{other_users[0].first_name.capitalize} also chose this recipe!"
            end
          puts ''
          is_running = false
          self.add_to_shopping_list(this_user, new_recipe)

        elsif answer == "n"
          puts ''
          puts "Okay, well let's look for a better recipe!"
          puts ''
          is_running = false
          self.options(this_user)

        else
          puts ''
          puts "Please enter a valid response!"
          puts ''
        end
      end
    end


    def self.add_to_shopping_list(this_user, new_recipe_or_from_box) #recipe - needs to be either last or the one you are viewing)
      is_running = true
      while is_running == true
        puts ''
        puts "Do you want to add the ingredients for this recipe to your shopping list? (Y/N)"
        puts ''
        answer = STDIN.gets.strip.downcase
        puts `clear`
        if answer == "y"
          new_recipe_or_from_box.ingredients.each do |ing|
            ShoppingListItem.create(user_id: this_user.id, ingredient_id: ing.id, is_complete: false)
            puts "Added #{ingredient.name}!"
          end
          is_running = false
          self.options(this_user)
        elsif answer == "n"
          puts `clear`
          puts ''
          puts "Wow you must have a good memory!"
          puts ''
          is_running = false
          self.options(this_user)
        else
          puts ''
          puts "Please enter a valid response!"
          puts ''
        end
    end


    def self.view_shopping_list(this_user)
       if this_user.shopping_list_items.length == 0
         puts ''
         puts "No list at the moment, we need to find recipes!!"
         puts ''
         self.options(this_user)
       else
         this_user.shopping_list_items.each do |item|
             if item.is_complete == true
               puts ''
               puts "(✓) #{item.ingredient.name}"
             else
               puts ''
               puts "( ) #{item.ingredient.name}"
             end
          end
       end
      is_running = true
        while is_running == true
          puts ''
          puts "What would you like to do?  Please enter a number: "
          puts ''
          puts "1. Check off item on list"
          puts ''
          puts "2. Clear shopping list"
          puts ''
          puts "3. Return to menu"
          puts ''
          input = STDIN.gets.strip
          if input == "1"
            self.check_off_items(this_user)
          elsif input == "2"
            this_user.shopping_list_items.each do |item|
              item.destroy
            end
              puts `clear`
              puts ''
              puts "List cleared!"
              puts ''
              is_running = false
              self.options(this_user)
          elsif input == "3"
            is_running = false
            self.options(this_user)
          else
            puts ''
            puts "Please enter a valid response!"
            puts ''
          end
        end
   end



   def self.check_off_items(this_user)
     puts "Which item can we check off your list?"
     input = STDIN.gets.strip.downcase
     puts `clear`
     this_user.shopping_list_items.each do |item|
       if item.ingredient.name == input && item.is_complete == false
         item.update(is_complete: true)
       elsif item.ingredient.name == input && item.is_complete == true
         puts "This item has already been checked off!"
       end
     end
     self.view_shopping_list(this_user)
   end

end
