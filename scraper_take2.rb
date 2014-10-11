# I'm sorry for this code
require "mongo_mapper"
require "json"
require "httparty"


MongoMapper.database = "food"
require_relative "model.rb"
require_relative "apikey.rb"

class Migros
  include HTTParty

  base_uri "https://test-web-api.migros.ch/eth-hack"

  def someProducts limit, offset
    respons = self.class.get("/products?key=#{API_KEY}&lang=de&limit=#{limit}&offset=#{offset}&sort=category&roots=lebensmittel")
    responsJson = JSON.parse respons.body if respons.code == 200
    products = responsJson["products"]
    products
  end
end

scraper = Migros.new

totalResult = 100

element_counter = 0
(0..50).each_with_index do |item, index|
  prod = scraper.someProducts totalResult, totalResult * index

  for product in prod do
    unless product[1]["image"].nil?

      categories = product[1]["categories"]
      if categories.to_s.include? "lebensmittel"

        facts = product[1]["nutrition_facts"]
        unless facts.nil? || facts["standard"].nil? || facts["standard"]["nutrients"].nil?
          url = "http://#{product[1]["image"]["large"]}".split(".jpg")[0]
          db_product = Product.new(:productNummber => product[0],
                                   :name => product[1]["name"],
                                   :imgurl =>  "#{url}.jpg",
                                   :rnd => rand())

          for nut in product[1]["nutrition_facts"]["standard"]["nutrients"]
            db_product.nutritions.build(:name => nut["name"], :unit => nut["quantity_unit"], :quantity => nut["quantity"])
          end

          db_product.save!

          element_counter = element_counter + 1
        end
      end
    end
  end
end

p element_counter
