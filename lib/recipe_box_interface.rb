require_relative '../config/environment.rb'

class RecipeBoxCLI

  RECIPE_API = 'http://www.recipepuppy.com/api/'

  def self.welcome
    puts `clear`
    puts ''
    puts <<-'IMG'
    __          __  _                            _          _____           _              ____            _
    \ \        / / | |                          | |        |  __ \         (_)            |  _ \          | |
     \ \  /\  / /__| | ___ ___  _ __ ___   ___  | |_ ___   | |__) |___  ___ _ _ __   ___  | |_) | _____  __ |
      \ \/  \/ / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \  |  _  // _ \/ __| | '_ \ / _ \ |  _ < / _ \ \/ / |
       \  /\  /  __/ | (__ (_) | | | | | |  __/ | |_ (_) | | | \ \  __/ (__| | |_) |  __/ | |_) | (_) >  <|_|
        \/  \/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/  |_|  \_\___|\___|_| .__/ \___| |____/ \___/_/\_(_)
                                                                             | |
                                                                             |_|
    IMG
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
      puts `clear`
      puts ''
      puts "Hi #{this_user.first_name.capitalize}, I'm so glad you decided to join!  Your account has been created.  Get ready to cook!"
      puts ''
      self.options(this_user)
    else
      this_user = User.find_by(first_name: first_name, last_name: last_name)
      puts `clear`
      puts ''
      puts "Welcome back #{this_user.first_name.capitalize}!  You must be hungry!"
      puts ''
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
             puts <<-'IMG'
             __  ____     __  _____  ______ _____ _____ _____  ______   ____   ______   __
            |  \/  \ \   / / |  __ \|  ____/ ____|_   _|  __ \|  ____| |  _ \ / __ \ \ / /
            | \  / |\ \_/ /  | |__) | |__ | |      | | | |__) | |__    | |_) | |  | \ V /
            | |\/| | \   /   |  _  /|  __|| |      | | |  ___/|  __|   |  _ <| |  | |> <
            | |  | |  | |    | | \ \| |____ |____ _| |_| |    | |____  | |_) | |__| / . \
            |_|  |_|  |_|    |_|  \_\______\_____|_____|_|    |______| |____/ \____/_/ \_\

             IMG
             my_recipes.each_with_index{|recipe, index|
               puts ""
               puts "#{index + 1}. #{recipe.title}"
               puts ""
             }
             running = true
             while running
             puts ''
             puts "If you want to view one of your recipes please type its number, or, type 'back' to return to the menu: "
             puts ''
             input = STDIN.gets.strip
               if input.downcase == "back"
                 puts `clear`
                 break
               elsif input.to_i != 0 && (0..my_recipes.length).include?(input.to_i)
                 recipe_from_box = my_recipes[input.to_i - 1]
                 puts `open #{recipe_from_box.url}`
                 running = false
                 self.add_to_shopping_list(this_user, recipe_from_box)
               else
                 puts ''
                 puts "Please enter a valid response!"
                 puts ''
               end
             end
           end
       elsif choice == "4"
         self.view_shopping_list(this_user)
       elsif choice == "5"
         puts ''
         puts <<-'IMG'
              _____                 _ _                _
             / ____|               | | |              | |
            | |  __  ___   ___   __| | |__  _   _  ___| |
            | | |_ |/ _ \ / _ \ / _` | '_ \| | | |/ _ \ |
            | |__| | (_) | (_) | (_| | |_) | |_| |  __/_|
             \_____|\___/ \___/ \__,_|_.__/ \__, |\___(_)
                                             __/ |
                                            |___/
         IMG
         puts ''
         exit(true)
       else
         puts ''
         puts "Please enter a valid response!"
         puts ''
       end
    end
  end

  def self.recipe_search_by_ingredient(this_user)
    running = true
    puts ''
    puts "Tell me your ingredient: "
    puts ''
    while running
       answer = STDIN.gets.strip.downcase
       url = RECIPE_API + "?i=#{answer}"
       json = get_json(url)
       if json["results"].length == 0 && answer.downcase != 'back'
         puts ''
         puts "So sorry, but I can't find anything with that ingredient!  Please try again, or type 'back' to return to the menu and try searching by keyword:"
         puts ''
       elsif answer == 'back'
         puts `clear`
         running = false
       else
         recipe_list_array = []
         json["results"].each_with_index {|hash, index|
           indexed_item = "#{index + 1}. #{hash["title"].gsub(/[^A-Z\/\-\' ]|\t\r\n\f\v/i, '')}"
           puts ''
           puts indexed_item
           puts ''
           recipe_list_array << indexed_item
         }
         self.select_recipe(this_user, url, recipe_list_array)
         running = false
       end
    end
  end

  def self.recipe_search_by_word(this_user)
    running = true
    puts ''
    puts "What keyword or title should I search for?"
    puts ''
    while running
       answer = STDIN.gets.chomp.downcase
       url = RECIPE_API + "?q=#{answer}"
       json = get_json(url)
       if json["results"].length == 0
         puts ''
         puts "So sorry, but I can't find anything with that title or keyword!  Please try again, or type 'back' to return to the menu:"
         puts ''
       elsif answer == 'back'
         puts `clear`
         running = false
       else
         recipe_list_array = []
         json["results"].each_with_index {|hash, index|
           indexed_item = "#{index + 1}. #{hash["title"].gsub(/[^A-Z\/\-\' ]|\t\r\n\f\v/i, '')}"
           puts ''
           puts indexed_item
           puts ''
           recipe_list_array << indexed_item
         }
         self.select_recipe(this_user, url, recipe_list_array)
         running = false
       end
    end
  end

  def self.select_recipe(this_user, url, recipe_list_array)
    i = 1
    more = true
    answer1 = nil
    json = get_json(url)
    while more == true
       puts ''
       puts "Type the number of the recipe you want to view, or, 'more' to see more recipes, or, 'back' to return to the menu: "
       puts ''
       answer1 = STDIN.gets.strip
       if answer1.downcase == 'more'
         puts `clear`
         i += 1
         url1 = url + "&p=#{i}"
         begin
           json = get_json(url1)
           length = recipe_list_array.length
           json["results"].each_with_index {|hash, index|
             indexed_item = "#{index + 1 + length}. #{hash["title"].strip}"
             puts ''
             puts indexed_item
             puts ''
             recipe_list_array << indexed_item
           }
         rescue RestClient::InternalServerError
           puts "Bummer, there are no more recipes to view!"
           more = false
         end
       elsif answer1.downcase == 'back'
         puts `clear`
         more = false
         # self.options(this_user)
       elsif !(1..recipe_list_array.length).include?(answer1.to_i) && answer1.downcase != "more" && answer1.downcase != "back"
         puts ''
         puts "Please enter a valid response!"
         puts ''
       else
         more = false
         recipe_w_index = recipe_list_array.find{|recipe| recipe.include?(answer1)}
         recipe = recipe_w_index[answer1.length + 2..recipe_w_index.length - 1]
         json["results"].each do |hash|
          hash.each do |k, v|
            if v.include?(recipe)
              Recipe.create("title": v, "url": hash["href"])
              ingredients_string = hash["ingredients"]
              ingredient_array = ingredients_string.split(", ")
              ingredient_array.each do |item_string|
                Ingredient.create(name: item_string.downcase)
                Recipe.last.ingredients << Ingredient.last
                Recipe.last.save
              end
             url2 = hash["href"]
             puts `open #{url2}`
            end
          end
         end
         new_recipe = Recipe.last
         self.recipe_box_or_no(this_user, new_recipe)
       end
     end
  end

    def self.recipe_box_or_no(this_user, new_recipe)
      running = true
      while running
         puts `clear`
         puts ''
         puts "Would you like to add this recipe to your recipe box? (Y/N)"
         puts ''
         answer = STDIN.gets.strip.downcase
         if answer == "y"
           this_user.recipes << new_recipe
           this_user.save
           other_users = User.all.select{|user| user.recipes.include?(new_recipe)}
           puts ''
           puts "Done! Great choice, #{this_user.first_name.capitalize}!"
           puts ''
           if other_users.length > 0 && other_users[0].full_name != this_user.full_name
             puts "Hey, this is cool!  Another user named #{other_users[0].first_name.capitalize} also chose this recipe!  You have good taste!"
           end
           puts ''
           self.add_to_shopping_list(this_user, new_recipe)
           running = false
         elsif answer == "n"
           puts `clear`
           puts ''
           puts "Okay, well let's look for a better recipe!"
           running = false
         else
           puts ''
           puts "Please enter a valid response!"
           puts ''
         end
       end
    end


    def self.add_to_shopping_list(this_user, new_recipe_or_from_box)
      running = true
      while running
        puts ''
        puts "Do you want to add the ingredients for this recipe to your shopping list? (Y/N)"
        puts ''
        answer = STDIN.gets.strip.downcase
        puts `clear`
        if answer == "y"
          new_recipe_or_from_box.ingredients.each do |ing|
            this_user.shopping_list_items.create(user_id: this_user.id, ingredient_id: ing.id, is_complete: false)
            puts ''
            puts ''
            puts "Added #{ing.name}!"
          end
          puts ''
          puts ''
          puts ''
          break
        elsif answer == "n"
          puts `clear`
          puts ''
          puts "Wow, you must have a good memory!"
          puts ''
          break
        else
          puts ''
          puts "Please enter a valid response!"
          puts ''
        end
     end
   end

    def self.view_shopping_list(this_user)
        if this_user.shopping_list_items.length == 0
           puts ''
           puts "No list at the moment, we need to find recipes!!"
           puts ''
        else
          running = true
          while running
            this_user.shopping_list_items.each do |item|
               if item.is_complete == true
                 puts ''
                 puts "(✓) #{item.ingredient.name}"
               else
                 puts ''
                 puts "( ) #{item.ingredient.name}"
               end
            end
            puts ''
            puts ''
            puts ''
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
              running = false
            elsif input == "2"
              this_user.shopping_list_items.destroy_all
              puts `clear`
              puts ''
              puts "List cleared!"
              puts ''
              # self.options(this_user)
              running = false
            elsif input == "3"
              puts `clear`
              # self.options(this_user)
              running = false
            else
              puts ''
              puts "Please enter a valid response!"
              puts ''
            end
          end
        end
    end

   def self.check_off_items(this_user)
     running = true
     count = 0
     while running
       puts "Which item can we check off your list?"
       input = STDIN.gets.strip.downcase
       puts ''
       matches_arr = this_user.shopping_list_items.select{ |item|
         item.ingredient.name.downcase == input }
       if matches_arr.length == 0 && count == 0
          puts "Hmm, I don't see that item on your list, please try again."
          puts ''
          count += 1
       elsif matches_arr.length == 0 && count == 1
         puts ''
         puts "Still not seeing it...let's go back to the main menu and start over."
         break
       else
         matches_arr.each do |item|
           item.update(is_complete: true)
         end
         puts `clear`
         self.view_shopping_list(this_user)
         running = false
       end
     end
   end

end
