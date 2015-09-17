module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    register_task default_title: "Billing", default_role: "author"

    def self.nested_questions
      questions = []

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "first_name",
        value_type: "text",
        text: "First Name"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "last_name",
        value_type: "text",
        text: "Last Name"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "title",
        value_type: "text",
        text: "Title"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "department",
        value_type: "text",
        text: "Department"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "phone_number",
        value_type: "text",
        text: "Phone"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "email",
        value_type: "text",
        text: "Email"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "address1",
        value_type: "text",
        text: "Address Line 1 (optional)"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "address2",
        value_type: "text",
        text: "Address Line 2 (optional)"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "city",
        value_type: "text",
        text: "City"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "state",
        value_type: "text",
        text: "State or Province"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "postal_code",
        value_type: "text",
        text: "ZIP or Postal Code"
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def active_model_serializer
      TaskSerializer
    end
  end
end
