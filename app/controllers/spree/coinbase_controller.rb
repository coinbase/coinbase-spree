require 'httparty'

module Spree
  class CoinbaseController < StoreController
  	include HTTParty
  	ssl_ca_file File.expand_path(File.join(File.dirname(__FILE__), 'ca-coinbase.crt'))
  	skip_before_filter :verify_authenticity_token

	def redirect
		order = current_order || raise(ActiveRecord::RecordNotFound)

		if order.state != "payment"
			redirect_to root_url() # Order is not ready for payment / has already been paid
			return
		end

		# Create Coinbase button code
		secret_token = SecureRandom.base64(30)
		button_params = { :button => {
				:name => "Order #%s" % order.number,
				:price_string => order.total,
				:price_currency_iso => order.currency,
				:custom => order.id,
				:custom_secure => true,
				:callback_url => spree_coinbase_callback_url(:payment_method_id => params[:payment_method_id], :secret_token => secret_token),
				:cancel_url => spree_coinbase_cancel_url(:payment_method_id => params[:payment_method_id]),
				:success_url => spree_coinbase_success_url(:payment_method_id => params[:payment_method_id], :order_num => order.number),
				:info_url => root_url(),
				} }
		result = make_coinbase_request :post, "/buttons", button_params
		code = result["button"]["code"]

		if code
			# Add a payment in "checkout" state that is used to verify the callback
			transaction = CoinbaseTransaction.new
			transaction.button_id = code
			transaction.secret_token = secret_token
			payment = order.payments.create({:amount => 0,
											:source => transaction,
											:payment_method => payment_method })

			use_off_site = payment_method.preferred_use_off_site_payment_page
			redirect_to "https://coinbase.com/%1$s/%2$s" % [use_off_site ? "checkouts" : "inline_payments", code]
		else
			redirect_to edit_order_checkout_url(order, :state => 'payment'),
                    :notice => Spree.t(:spree_coinbase_checkout_error)
		end
	end

	def callback

		# Download order information from Coinbase (do not trust sent order information)
		cb_order_id = params["order"]["id"]
		cb_order = make_coinbase_request :get, "/orders/%s" % cb_order_id, {}

		if cb_order.nil?
 			render text: "Invalid order ID", status: 400
 			return
		end

		cb_order = cb_order["order"]

		if cb_order["status"] != "completed"
 			render text: "Invalid order status", status: 400
 			return
		end

		# Fetch Spree order information, find relevant payment, and verify button_id
		order_id = cb_order["custom"]
		order = Spree::Order.find(order_id)
		button_id = cb_order["button"]["id"]
		payments = order.payments.where(:state => "checkout",
                                      :payment_method_id => payment_method)
		payment = nil
		payments.each do |p|
			if p.source.button_id == button_id
				payment = p
			end
 		end

 		if payment.nil?
 			render text: "No matching payment for order", status: 400
 			return
 		end

 		# Verify secret_token
 		if payment.source.secret_token != params[:secret_token]
 			render text: "Invalid secret token", status: 400
 			return
 		end

 		# Now that this callback has been verified, process the payment!
 		transaction = payment.source
 		transaction.order_id = cb_order_id
 		transaction.save

 		# Make payment pending -> make order complete -> make payment complete -> update order
 		payment.amount = order.total
 		order.next
 		if !order.complete?
 			render text: "Could not transition order: %s" % order.errors
 			return
 		end
 		payment.complete!
 		order.update!

 		# Successful payment!
 		render text: "Callback successful"

	end

	def cancel

		order = current_order || raise(ActiveRecord::RecordNotFound)

		# Void the 'pending' payment created in redirect
		# If doing an on-site checkout params will be nil, so just
		# cancel all Coinbase payments (it is unlikely there will be more than one)
		button_id = params["order"]["button"]["id"] rescue nil
		payments = order.payments.where(:state => "pending",
                                      :payment_method_id => payment_method)
		payments.each do |payment|
			if payment.source.button_id == button_id || button_id.nil?
				payment.void!
			end
 		end

		redirect_to edit_order_checkout_url(order, :state => 'payment'),
			:notice => Spree.t(:spree_coinbase_checkout_cancelled)
	end

	def success

		order = Spree::Order.find_by_number(params[:order_num]) || raise(ActiveRecord::RecordNotFound)

		if order.complete?
          	session[:order_id] = nil # Reset cart
			redirect_to spree.order_path(order), :notice => Spree.t(:order_processed_successfully)
		end

		# If order not complete, wait for callback to come in... (page will automatically refresh, see view)
	end

	private

	def payment_method
		m = Spree::PaymentMethod.find(params[:payment_method_id])
		if !(m.is_a? Spree::PaymentMethod::Coinbase)
			raise "Invalid payment_method_id"
		end
		m
	end

	# the coinbase-ruby gem is not used because of its dependence on incompatible versions of the money gem
	def make_coinbase_request verb, path, options

		key = payment_method.preferred_api_key
		secret = payment_method.preferred_api_secret

		if key.nil? || secret.nil?
			raise "Please enter an API key and secret in Spree payment method settings"
		end

		base_uri = "https://coinbase.com/api/v1"
		nonce = (Time.now.to_f * 1e6).to_i
		message = nonce.to_s + base_uri + path + options.to_json
		signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), secret, message)

		headers = {
		'ACCESS_KEY' => key,
		'ACCESS_SIGNATURE' => signature,
		'ACCESS_NONCE' => nonce.to_s,
		"Content-Type" => "application/json",
		}

		r = self.class.send(verb, base_uri + path, {headers: headers, body: options.to_json})
		JSON.parse(r.body)
	end
  end
end