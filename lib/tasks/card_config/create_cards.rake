require_relative "./support/card_creator"

namespace "card_config" do
  desc "Convert NestedQuestionAnswers to Answers and associate cards to Answerables"
  task convert_nested_questions: [:environment, :clean] do
    puts "------------------- Convert Nested Questions Answers Start ----------------------------"
    answerables = ObjectSpace.each_object(Class).select { |c| c.included_modules.include? Answerable } - [Task]
    answerables.each do |klass|
      puts "+++ converting nested question answers for #{klass.name}"
      CardConfig::CardCreator.new(owner_klass: klass).call
    end
    puts "------------------- Convert Nested Questions Answers End ----------------------------"
  end

  task clean: :environment do
    # acts as paranoid cleanup for new models
    Answer.delete_all!
  end
end
