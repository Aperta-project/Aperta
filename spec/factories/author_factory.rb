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

FactoryGirl.define do
  factory :author do
    paper
    card_version

    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    author_initial "LS"
    email
    department "Jedis"
    title "Head Jedi"
    affiliation 'university of dagobah'
    co_author_state_modified_at DateTime.current

    trait :corresponding do
      after(:create) do |author|
        corresponding_author_question = CardContent.find_by!(
          ident: Author::CORRESPONDING_QUESTION_IDENT
        )
        corresponding_author_question.answers.create(owner: author, paper: author.paper, value: 't')
      end
    end

    trait :contributions do
      after(:create) do |author|
        contributions_author_question = CardContent.find_by!(
          ident: Author::CONTRIBUTIONS_QUESTION_IDENT
        )
        contributions_author_question.answers.create(owner: author, paper: author.paper, value: 't')
      end
    end
  end
end
