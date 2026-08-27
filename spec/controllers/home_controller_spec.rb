require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "показывает в блоке брендов только публичные компании" do
      public_brand  = create(:company, public_status: Publishable::PUBLIC, forward_brand: true)
      private_brand = create(:company, public_status: Publishable::PRIVATE, forward_brand: true)

      get :index

      expect(assigns(:forward_brands)).to include(public_brand)
      expect(assigns(:forward_brands)).not_to include(private_brand)
    end
  end

  describe "GET #about" do
    it "returns http success" do
      get :about
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #contact" do
    it "returns http success" do
      get :contact
      expect(response).to have_http_status(:success)
    end
  end

end
