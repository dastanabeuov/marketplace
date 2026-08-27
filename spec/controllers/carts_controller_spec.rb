require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  let!(:public_product)  { create(:product, public_status: Publishable::PUBLIC) }
  let!(:private_product) { create(:product, public_status: Publishable::PRIVATE) }

  describe "POST #add_item" do
    it "кладёт публичный продукт в корзину" do
      post :add_item, params: { product_id: public_product.id }

      expect(response).to redirect_to(cart_path)
      expect(session[:cart]).to eq(public_product.id.to_s => 1)
    end

    it "не кладёт приватный продукт в корзину" do
      post :add_item, params: { product_id: private_product.id }

      expect(response).to redirect_to(products_path)
      expect(session[:cart]).to be_blank
    end
  end

  describe "PATCH #update_quantity" do
    it "выбрасывает приватный продукт из корзины" do
      session[:cart] = { private_product.id.to_s => 2 }

      patch :update_quantity, params: { product_id: private_product.id, quantity: 5 }

      expect(response).to redirect_to(cart_path)
      expect(session[:cart]).to be_blank
    end
  end
end
