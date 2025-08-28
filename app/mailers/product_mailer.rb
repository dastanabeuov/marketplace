class ProductMailer < ApplicationMailer
  def new_product(product, subscription)
    @product = product
    @subscription = subscription
    @recipient_name = subscription.email

    mail(
      to: subscription.email,
      subject: I18n.t("new_product", product: @product.name)
    )
  end
end
