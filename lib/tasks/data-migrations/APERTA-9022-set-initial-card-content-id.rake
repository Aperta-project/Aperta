namespace :data do
  namespace :migrate do
    namespace :cards do
      desc 'Sets the card_content id sequence to not conflict with nested_questions'
      task set_card_content_id: :environment do
        # To avoid id collision on the ember side, where we are making CardContent
        # look like NestedQuestion, do not reuse ids.
        start = NestedQuestion.pluck(:id).max.try(:+, 1)

        # Due to snafuness, this reset may have already run more than once (it wasn't
        # always in a migration). Just in case, reset to the max card_content.
        if CardContent.count > 0
          start = CardContent.pluck(:id).max.try(:+, 1)
        end

        if start.present?
          $stderr.puts("Starting CardContent.id sequence at #{start}")
          ActiveRecord::Base.connection.execute("ALTER SEQUENCE card_contents_id_seq RESTART WITH #{start}")
        end
      end
    end
  end
end
