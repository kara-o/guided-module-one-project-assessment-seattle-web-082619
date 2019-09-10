require 'json'
require 'rest-client'

recipe_api = 'http://www.recipepuppy.com/api/'

def get_recipes_from_api(url)
  response = RestClient.get(url)
  response_hash = JSON.parse(response.body)
  response_hash["results"]
end

def get_json(url)
  response = RestClient.get(url)
  json = JSON.parse(response.body)
end
