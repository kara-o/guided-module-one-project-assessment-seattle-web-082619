require_relative '../config/environment.rb'

class RecipeBoxCLI

#attr_accessor :is_running?

RECIPE_API = 'http://www.recipepuppy.com/api/'

@@recipe_list_array = []

@@url = nil

# def initialize
#   @is_running = false
#   @recipe_list = nil
# end

def self.welcome
  puts "Welcome to Recipe Box!"
  puts "What is your first name?"
  first_name = STDIN.gets.chomp.downcase
  puts "What is your last name?"
  last_name = STDIN.gets.chomp.downcase

  if User.all.select{|user| user.full_name == first_name + " " + last_name}.length == 0
    User.create(first_name: first_name, last_name: last_name)
    puts "Yay, I'm so glad you decided to join!  Your account has been created.  Get ready to cook!"
    self.options

  else
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
    indexed_item = "#{index + 1}. #{hash["title"].delete("\n")}"
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
    indexed_item = "#{index + 1}. #{hash["title"].delete("\n")}"
    puts indexed_item
    @@recipe_list_array << indexed_item
  }

  self.select_recipe
end

def self.select_recipe
  puts "Type the number of the recipe you want to view, or, type 'more' to see more recipes:"
  answer1 = STDIN.gets.chomp
  i = 1
  more = true
  if answer1 == 'more'
    while more == true do
    i += 1
    url = @@url + "&p=#{i}"
    json = get_json(url)
    length = @@recipe_list_array.length
    json["results"].each_with_index {|hash, index|
      indexed_item = "#{index + 1 + length}. #{hash["title"].delete("\n")}"
      puts indexed_item
      @@recipe_list_array << indexed_item
    }
    puts "Do you want to see more? (Y/N)"
      answer2 = STDIN.gets.chomp
      if answer2 == "Y"
        more = true
      elsif answer2 == "N"
        more = false
        puts "Type the number of the recipe you want to view:"
        answer1 = STDIN.gets.chomp
      end
    end
    binding.pry
    answer1 #this is the ultimate recipe choice, need to get to recipe
  end

end


end
