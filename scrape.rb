require "mongo_mapper"
require "json"
require "httparty"

class Migros
  include HTTParty

  base_uri "http://api.autoidlabs.ch"

  def categories id
    respons = self.class.get("/categories/#{id}")
    JSON.parse respons.body if respons.code == 200
  end

  def product ean
    respons = self.class.get("/products/#{ean}")
    JSON.parse respons.body if respons.code == 200
  end
end

SCRAPER = Migros.new

def loadProduct ean
  prod = SCRAPER.product ean
  puts ean
  unless prod["image"].nil?
    p "-------------------"
    p prod["name"]
  end
end

def loadCategories id
  cat = SCRAPER.categories id

  #loop over each product in this categorie
  unless cat["prodMbrs"].nil? || cat["prodMbrs"].length == 0
    for product in cat["prodMbrs"]

      ean = product["ean"]

=begin
      unless ean.nil?
        if ean.to_s.length != 0
          loadProduct ean
        end
      end
=end
    end
  end

  #loop over each categorie
  puts "...----......"
  puts cat["catMbrs"]
  if cat["catMbrs"].length != 0
    for catmbrs in cat["catMbrs"] do
      loadCategories catmbrs["id"]
    end
  end
end

loadCategories 1261349
