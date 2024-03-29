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

module TahiHelperMethods
  def res_body
    JSON.parse(response.body).with_indifferent_access
  end

  def user_select_hash(user)
    {id: user.id, full_name: user.full_name, avatar: user.image_url}
  end

  # NEW ROLES
  def assign_academic_editor_role(paper, user)
    FactoryGirl.create(:assignment,
                       role: paper.journal.academic_editor_role,
                       user: user,
                       assigned_to: paper)
  end

  def assign_author_role(paper, creator)
    creator.assign_to!(assigned_to: paper, role: paper.journal.creator_role)
  end

  def assign_task_participant_role(task, participant)
    participant.assign_to!(assigned_to: task, role: task.paper.journal.task_participant_role)
  end

  def assign_reviewer_role(paper, reviewer)
    reviewer.assign_to!(assigned_to: paper, role: paper.journal.reviewer_role)
  end

  def assign_handling_editor_role(paper, editor)
    editor.assign_to!(assigned_to: paper, role: paper.journal.handling_editor_role)
  end

  def assign_internal_editor_role(paper, editor)
    editor.assign_to!(assigned_to: paper, role: paper.journal.internal_editor_role)
  end

  def assign_production_staff_role(journal, user)
    user.assign_to!(assigned_to: journal, role: paper.journal.production_staff_role)
  end

  def assign_publishing_services_role(journal, user)
    user.assign_to!(assigned_to: journal, role: paper.journal.publishing_services_role)
  end

  def assign_journal_role(journal, user, role_or_type)
    if role_or_type == :admin
      user.assign_to!(assigned_to: journal, role: journal.journal_setup_role)
      user.assign_to!(assigned_to: journal, role: journal.staff_admin_role)
    elsif role_or_type == :editor
      user.assign_to!(assigned_to: journal, role: journal.internal_editor_role)
    end
  end

  def with_aws_cassette(name)
    ignored_attributes = ["X-Amz-Algorithm", "X-Amz-Credential", "X-Amz-Date", "X-Amz-Expires", "X-Amz-Signature", "X-Amz-SignedHeaders"]
    VCR.use_cassette(name, match_requests_on: [:method, VCR.request_matchers.uri_without_params(*ignored_attributes)], record: :new_episodes) do
      yield
    end
  end

  def insert_aws_cassette(name)
    ignored_attributes = ["X-Amz-Algorithm", "X-Amz-Credential", "X-Amz-Date", "X-Amz-Expires", "X-Amz-Signature", "X-Amz-SignedHeaders"]
    VCR.insert_cassette(name, match_requests_on: [:method, VCR.request_matchers.uri_without_params(*ignored_attributes)], record: :new_episodes)
  end

  def with_valid_salesforce_credentials
    sf_credentials       = Dotenv.load('.env.development').select{|k,_v| k.include? 'DATABASEDOTCOM'}
    old_test_credentials = sf_credentials.inject({}){|hash, el| hash[el[0]] = ENV[el[0]]; hash }

    sf_credentials.each {|k,v| ENV[k] = v} #use real creds

    yield

    old_test_credentials.each {|k,v| ENV[k] = v} #reset to dummy creds
  end

  def register_paper_decision(paper, verdict)
    decision = paper.draft_decision
    CardLoader.load("TahiStandardTasks::ReviseTask")

    task = paper.last_of_task(TahiStandardTasks::RegisterDecisionTask) ||
      create(:register_decision_task, :with_loaded_card, paper: paper)

    decision.update! verdict: verdict
    decision.register!(task)
  end
end
