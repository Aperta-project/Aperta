#
# This shared set of examples is for any Snapshot::Serializer that snapshots its
# nested questions generically (e.g. looping over and recursively snapshotting
# each one as opposed to looking for particular questions by an ident).
#
# An example of using it:
#
#   describe "snapshotting" do
#     # Must be provided
#     subject(:serializer){ SomeSerializer.new }
#     let(:task){ Task.new }
#     include_examples "snapshot serializes related nested questions", resource: :task
#   end
#
# The :resource is passed in as symbol because it tells the shared examples
# what +let+ variable to use when running the examples.
#
shared_examples_for "snapshot serializes related nested questions" do |opts|
  context "serializing related nested questions" do
    before do
      # find the corresponding +let+ variable
      resource = instance_eval opts[:resource].to_s

      unless serializer
        fail NotImplementError, <<-EOT.strip_heredoc
          Missing :serializer for shared examples. It needs to be provided
          by the calling spec. If you'd like to name this something else
          you will want to update this set of shared examples to allow
          for that since it doesn't currently allow that flexibility.
        EOT
      end

      unless resource
        fail NotImplementError, <<-EOT.strip_heredoc
          Missing :resource for shared examples. Please pass in
          `resource: :let_var_name_here` when including these examples.
        EOT
      end

      unless resource.respond_to?(:nested_questions)
        fail <<-EOT.strip_heredoc
          The given resource (#{resource.inspect}) doesn't respond to
          #nested_questions. It may not be implemented or you may not be passing
          in the right resource.
        EOT
      end

      # Remove any questions that may exist so we can construct our own
      # for the purpose of this test
      resource.class.nested_questions.delete_all

      nested_question_1 = FactoryGirl.create(
        :nested_question,
        id: 9001,
        owner_id: nil,
        owner_type: resource.class.name,
        ident: "question_1",
        text: "Question 1?",
        position: 2
      )
      nested_question_2 = FactoryGirl.create(
        :nested_question,
        id: 9002,
        owner_id: nil,
        owner_type: resource.class.name,
        ident: "question_2",
        text: "Question 2?",
        position: 1
      )

      expect(resource.nested_questions.sort_by(&:id)).to eq([nested_question_1, nested_question_2])
    end

    it "serializes each question" do
      children = serializer.as_json[:children]
      expect(children).to include(
        {
          name: "question_2",
          type: "question",
          value: { id: 9002, title: "Question 2?", answer_type: "text", answer: nil, attachments: [] },
          children: []
        },
        {
          name: "question_1",
          type: "question",
          value: { id: 9001, title: "Question 1?", answer_type: "text", answer: nil, attachments: [] },
          children: []
        }
      )
    end

    it "serializes the question by order of their respective position(s)" do
      children = serializer.as_json[:children]
      index_of_question_1 = children.index { |hsh| hsh[:name] == "question_1" }
      index_of_question_2 = children.index { |hsh| hsh[:name] == "question_2" }

      # nested_question_2 should come first
      expect(index_of_question_2 < index_of_question_1).to be(true)
    end
  end
end
