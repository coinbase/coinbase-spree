class CreateSpreeCoinbaseTransactions < ActiveRecord::Migration
  def change
    create_table :spree_coinbase_transactions do |t|
    	t.string :button_id
    	t.string :order_id
    	t.string :secret_token
    end
  end
end
