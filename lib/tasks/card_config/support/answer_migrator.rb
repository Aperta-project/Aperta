module CardConfig
  class AnswerMigrator

    attr_reader :nested_question, :card_content

    def initialize(nested_question:, card_content:)
      @nested_question = nested_question
      @card_content = card_content
    end

    def call
      Answer.transaction do
        nested_question.nested_question_answers.map do |nqa|
          migrate_answer!(nqa)
        end
      end
    end

    private

    def migrate_answer!(nested_question_answer)
      Answer.new do |answer|
        answer.card_content    = card_content
        answer.owner_id        = nested_question_answer.owner.id
        answer.owner_type      = nested_question_answer.owner_type
        answer.value           = nested_question_answer.value
        answer.paper_id        = nested_question_answer.paper_id
        answer.additional_data = nested_question_answer.additional_data
        answer.created_at      = nested_question_answer.created_at
        answer.updated_at      = nested_question_answer.updated_at

        migrate_attachments!(nested_question_answer, answer)

        answer.save!
      end
    end

    def migrate_attachments!(nested_question_answer, answer)
      nested_question_answer.attachments.all.map(&:dup).each do |attachment|
        attachment.owner = answer
        attachment.save!
      end
    end
  end
end
