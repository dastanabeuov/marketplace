class HomeController < ApplicationController
  def index
    @forward_brands = Company.forward_brands.limit(10)
  end
end
