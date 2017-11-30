namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11974:
      Convert the preprint-posting-consent value from (1|2) to (true|false),
      and its card_content value_type from text to boolean.
    DESC

    # rubocop:disable Rails/SkipsModelValidations  This is necessary.

    task aperta_11974_preprint_preprint_posting: :environment do
      card_contents = CardContent.where(ident: 'preprint-posting--consent').includes(:entity_attributes, :answers).all
      puts "Converting Card Contents [#{card_contents.size}]"
      card_contents.each do |card_content|
        next unless card_content.value_type == 'text'

        card_content.update_attribute(:value_type, 'boolean')
        card_content.reload

        values = card_content.possible_values
        values.each { |each| each['value'] = each['value'].to_i == 1 } # 1 => true, 2 => false
        card_content.possible_values = values
        card_content.save

        eav = card_content.entity_attributes.where(name: 'default_answer_value').first
        eav.update_attributes(value_type: 'boolean', boolean_value: eav.string_value == '1', string_value: nil)
        card_content.reload

        answers = card_content.answers
        puts "Converting Answers [#{answers.size}]"
        answers.each do |answer|
          answer.update_attribute(:value, answer[:value] == '1')
        end
      end
    end
  end
end
