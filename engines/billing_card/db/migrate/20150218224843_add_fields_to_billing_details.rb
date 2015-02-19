class AddFieldsToBillingDetails < ActiveRecord::Migration
  def change
    add_column :billing_card_billing_details, :author_confirmation, :boolean, default: false
    add_column :billing_card_billing_details, :payment_method, :string
  end
end
