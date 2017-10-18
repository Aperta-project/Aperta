namespace :data do
  namespace :migrate do
    desc <<-DESC
      This removes the nested if statement from letter templates that include reviewer comments,
      replacing it with a new merge field "rendered_answers"
    DESC
    task add_rendered_answers_mergefield: :environment do
      regex = /{%- for answer in review.answers -%}.+?{%- endfor -%}/m

      replacement = <<-TEXT.strip_heredoc
        {%- for answer in review.rendered_answers -%}
              <p>
                {{ answer.value }}
              </p>
              {%- endfor -%}
        TEXT

      LetterTemplate.where("body like '%rendered_answer_idents%'").each do |row|
        new_body = row.body.gsub(regex, replacement)
        throw "Body after text replace unchanged" if row.body == new_body
        row.update!(body: new_body)
      end
    end
  end
end
