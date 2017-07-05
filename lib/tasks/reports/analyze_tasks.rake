# rubocop:disable Style/IndentationWidth
# rubocop:disable Style/ElseAlignment
# rubocop:disable Lint/EndAlignment
# rubocop:disable Style/EmptyElse

namespace :reports do
  task analyze_tasks: :environment do
    papers = balanced = unbalanced = newlines = both = 0

    inactive_states = %w(rejected withdrawn accepted)
    current_papers = Paper.select(:id).where.not(publishing_state: inactive_states).pluck(:id).map(&:to_i)

    Paper.where(id: current_papers).order(:id).all.each do |paper|
      papers += 1
      paper_tasks = paper.tasks.group_by(&:type)
      paper_tasks.each do |type, tasks|
        next if tasks.empty?

        tasks.each do |task|
          answers = task.answers.load
          next if answers.empty?

          answers.each do |answer|
            text = answer.value
            next unless text.is_a? String
            next if text.blank?

            has_returns = text =~ /\n/
            newlines += 1 if has_returns

            matched = text =~ /\<[\S].*\>/
            balanced += 1 if matched

            unmatched = text =~ /(\<[\S])|(\>[\S])/
            unbalanced += 1 if unmatched

            brackets = matched || unmatched
            messy = has_returns && brackets
            both += 1 if messy

            tag = if messy
              "*** Newlines and Brackets"
            elsif matched
              "*+* matched brackets"
            elsif unmatched
              "*-* unmatched brackets"
            elsif has_returns
              "*?* Newlines [#{text.length}]"
            else
              nil
            end

            puts "\nPaper [#{paper.id}] #{type} [#{tasks.count}] Answer #{answer.card_content.ident} [#{answer.id}]: #{tag} \n#{text.gsub("\n", '\n')}\n" if tag
          end
        end
      end
    end
    puts "Papers: #{papers}, (NewLines: #{newlines}, Balanced: #{balanced}, Unbalanced: #{unbalanced}, Both: #{both})"
  end
end
