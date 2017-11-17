namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11974:
      Convert the preprint-posting-consent value from (1|2) to (true|false),
      and its card_content value_type from text to boolean.
    DESC

    task aperta_11974_preprint_preprint_posting: :environment do
      card_contents = CardContent.where(ident: 'preprint-posting--consent').includes(:content_attributes, :answers).all
      puts "Converting Card Contents [#{card_contents.size}]"
      card_contents.each do |card_content|
        next unless card_content.value_type == 'text'
        answers = card_content.answers
        puts "Converting Answers [#{answers.size}]"
        answers.each do |answer|
          answer.update_attributes(value: answer.value.to_i == 1)
        end
        card_content.update_attributes(value_type: 'boolean')
      end
    end
  end
end
