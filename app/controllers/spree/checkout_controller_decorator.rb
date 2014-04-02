module Spree
  CheckoutController.class_eval do
    before_filter :coinbase_redirect, :only => [:update]

    private
    def coinbase_redirect
      return unless (params[:state] == "payment") && params[:order][:payments_attributes]

      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      if payment_method.kind_of?(Spree::PaymentMethod::Coinbase)
        redirect_to spree_coinbase_redirect_url(:payment_method_id => payment_method.id)
      end
    end
  end
end