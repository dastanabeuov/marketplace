require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:public_product)  { create(:product, public_status: Publishable::PUBLIC) }
  let!(:private_product) { create(:product, public_status: Publishable::PRIVATE) }

  describe "GET #index" do
    it "показывает только публичные продукты" do
      get :index

      expect(assigns(:products)).to include(public_product)
      expect(assigns(:products)).not_to include(private_product)
    end

    it "не предлагает приватные компании в фильтрах" do
      public_company  = create(:company, public_status: Publishable::PUBLIC)
      private_company = create(:company, public_status: Publishable::PRIVATE)

      get :index

      expect(assigns(:companies)).to include([ public_company.id, public_company.name ])
      expect(assigns(:companies)).not_to include([ private_company.id, private_company.name ])
    end

    it "не показывает продукты при фильтре по приватной компании" do
      private_company = create(:company, public_status: Publishable::PRIVATE)
      private_company.products << public_product

      get :index, params: { company_id: private_company.id }

      expect(assigns(:products)).to be_empty
    end
  end

  describe "GET #show" do
    it "открывает публичный продукт" do
      get :show, params: { id: public_product.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:product)).to eq(public_product)
    end

    it "редиректит с приватного продукта в каталог" do
      get :show, params: { id: private_product.id }

      expect(response).to redirect_to(products_path)
      expect(assigns(:product)).to be_nil
    end
  end
end
