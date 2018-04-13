# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# rubocop:disable Layout/IndentationWidth
# rubocop:disable Layout/ElseAlignment
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
            next unless answer.card_content.value_type == 'html'

            text = answer.value
            next unless text.is_a? String
            next if text.blank?

            text = HtmlScrubber.standalone_scrub!(text)
            has_returns = text =~ /\n/
            newlines += 1 if has_returns

            matched = text =~ /\<[\S].*\>/
            balanced += 1 if matched

            unmatched = text =~ /(\<[\S])|([\S]\>)/
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
