class CreateBillingCardBillingDetails < ActiveRecord::Migration
  def change
    create_table :billing_card_billing_details do |t|
      t.integer :journal_id
      t.integer :paper_id

      t.text :pfa_funding_statement

      t.text :pfa_question_1
      t.text :pfa_question_1a
      t.text :pfa_question_1b

      t.text :pfa_question_2
      t.text :pfa_question_2a
      t.text :pfa_question_2b

      t.text :pfa_question_3
      t.text :pfa_question_3a

      t.text :pfa_question_4
      t.text :pfa_question_4a

      t.text :pfa_amount_to_pay
      t.text :pfa_supporting_docs
      t.text :pfa_additional_comments

      # User Details
      t.text :first_name
      t.text :last_name
      t.text :title
      t.text :department
      t.text :affiliation1
      t.text :affiliation2
      t.text :phone_number
      t.text :email_address
      t.text :address1
      t.text :address2
      t.text :city
      t.text :state
      t.text :postal_code
      t.text :country

      t.timestamps null: false
    end
  end
end
