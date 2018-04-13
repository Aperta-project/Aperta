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
  factory :invitation do
    invitee_role 'Some Role'
    email "email@example.com"
    paper { create(:paper) }
    task { create(:invitable_task, paper: paper) }
    association(:invitee, factory: :user)
    association(:actor, factory: :user)
    decision { paper.draft_decision || paper.new_draft_decision! }
    invitation_queue { create(:invitation_queue, task: task) }
    body "You've been invited to"
    position 0 # position column is null: false

    after(:build) do |invitation, evaluator|
      FactoryGirl.create(:letter_template, :academic_editor_invite, journal: invitation.paper.journal) unless LetterTemplate.exists?(journal: invitation.paper.journal, ident: "academic-editor-invite")
      FactoryGirl.create(:letter_template, :reviewer_invite, journal: invitation.paper.journal) unless LetterTemplate.exists?(journal: invitation.paper.journal, ident: "reviewer-invite")
      invitation.email = evaluator.invitee.email if evaluator.invitee
    end

    # Ensure that these associations are saved if necessary.
    # (We `build` them above)
    after(:create) do |invitation|
      invitation.task.try(:save)
      invitation.decision.try(:save)
    end

    trait :invited do
      state "invited"
    end

    trait :accepted do
      state "accepted"
    end

    trait :declined do
      state "declined"
    end
  end
end
