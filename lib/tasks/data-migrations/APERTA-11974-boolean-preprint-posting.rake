namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11974:
      Convert the preprint-posting-consent value from (1|2) to (true|false),
      and its card_content value_type from text to boolean.
    DESC

    def truthy(value)
      value.in?([true, 'true', 1, '1']) ? 'true' : 'false'
    end

    task aperta_11974_boolean_preprint_posting: :environment do
      card_contents = CardContent.where(ident: 'preprint-posting--consent').includes(:entity_attributes, :answers).all
      puts "Converting Card Contents [#{card_contents.size}]"

      card_contents.each do |card_content|
        values = card_content.possible_values
        values.each { |each| each['value'] = truthy(each['value']) } # 1 => true, 2 => false
        card_content.possible_values = values

        card_content.default_answer_value = truthy(card_content.default_answer_value)
        card_content.reload

        card_content.value_type = "boolean"
        card_content.save!

        answers = card_content.answers
        puts "Converting Answers [#{answers.size}]"

        answers.each do |answer|
          answer.value = truthy(answer[:value])
          answer.save!
        end
      end
    end
  end
end
