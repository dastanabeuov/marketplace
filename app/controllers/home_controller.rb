class HomeController < ApplicationController
  def index
    @forward_brands = Company.publicly_visible.forward_brands.limit(10)
  end
end
