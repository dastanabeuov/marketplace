require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let!(:public_company)  { create(:company, public_status: Publishable::PUBLIC) }
  let!(:private_company) { create(:company, public_status: Publishable::PRIVATE) }

  describe "GET #index" do
    it "показывает только публичные компании" do
      get :index

      expect(assigns(:companies)).to include(public_company)
      expect(assigns(:companies)).not_to include(private_company)
    end

    it "не предлагает приватные компании в фильтрах" do
      get :index

      expect(assigns(:company_filters)).to include([ public_company.id, public_company.name ])
      expect(assigns(:company_filters)).not_to include([ private_company.id, private_company.name ])
    end
  end

  describe "GET #show" do
    it "открывает публичную компанию" do
      get :show, params: { id: public_company.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:company)).to eq(public_company)
    end

    it "редиректит с приватной компании в список" do
      get :show, params: { id: private_company.id }

      expect(response).to redirect_to(companies_path)
    end

    it "не показывает приватные продукты публичной компании" do
      public_product  = create(:product, public_status: Publishable::PUBLIC)
      private_product = create(:product, public_status: Publishable::PRIVATE)
      public_company.products << [ public_product, private_product ]

      get :show, params: { id: public_company.id }

      expect(assigns(:products)).to include(public_product)
      expect(assigns(:products)).not_to include(private_product)
    end
  end

  describe "GET #product" do
    it "редиректит с приватного продукта на страницу компании" do
      private_product = create(:product, public_status: Publishable::PRIVATE)
      public_company.products << private_product

      get :product, params: { id: public_company.id, product_id: private_product.id }

      expect(response).to redirect_to(company_path(public_company))
    end

    it "редиректит в список компаний, если компания приватная" do
      product = create(:product, public_status: Publishable::PUBLIC)
      private_company.products << product

      get :product, params: { id: private_company.id, product_id: product.id }

      expect(response).to redirect_to(companies_path)
    end
  end
end
