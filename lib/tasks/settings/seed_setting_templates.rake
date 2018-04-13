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

namespace :settings do
  desc "create entries in the template_settings table"
  # Since Settings can belong to any type of owner, we need to have some
  # place to define what Settings a given owner will have at runtime.
  # This includes possible values and a default value
  # For the time being the ithenticate_automation setting is the only entry.
  task seed_setting_templates: :environment do
    [{ journal: nil,
       key: "TaskTemplate:TahiStandardTasks::SimilarityCheckTask",
       value_type: "string",
       global: true,
       setting_klass: "Setting",
       setting_name: "ithenticate_automation",
       value: "off",
       possible_setting_values: [
         "off",
         "at_first_full_submission",
         "after_any_first_revise_decision",
         "after_minor_revise_decision",
         "after_major_revise_decision"
       ] },
     {
       journal: nil,
       key: "TaskTemplate:TahiStandardTasks::PaperReviewerTask",
       value_type: "integer",
       global: true,
       setting_klass: "Setting",
       setting_name: "review_duration_period",
       value: 10
     },
     {
       journal: nil,
       key: "Journal",
       value_type: "boolean",
       global: true,
       setting_klass: "Setting",
       setting_name: "coauthor_confirmation_enabled",
       value: false
     }].each do |hash|
      SettingTemplate.transaction do
        possible_values = hash.delete(:possible_setting_values) { |_el| [] }
        template_value = hash.delete(:value)
        s = SettingTemplate.find_or_initialize_by(hash)
        s.value = template_value
        s.save!
        value_type = hash[:value_type]
        possible_values.each do |v|
          PossibleSettingValue.create(
            value_type: value_type,
            value: v,
            setting_template: s
          )
        end
      end
    end
  end
end
