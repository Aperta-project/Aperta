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

# Configurable models have related Settings stored in the database
# New settings can be initialized by adding a setting template
# at lib/tasks/settings/seed_setting_templates.rake and then running:
# `$ rake settings:seed_setting_templates`
# that setting value can then be accessed with:
# `owner.setting(<setting_name>).value` and updated by updating the
# object that `owner.setting(<setting_name>)` returns

module Configurable
  extend ActiveSupport::Concern

  # even though a configurable has_many settings,
  # accessing any given setting shouldn't happen through the
  # has_many directly, but rather through the `setting` method
  included do
    has_many :settings, as: :owner, dependent: :destroy
  end

  # setting templates for a given key will be global ones (where journal id is
  # nil) or ones where journal is this Configurable's journal
  def setting_templates
    journals = respond_to?(:journal) ? [nil, journal] : [nil]
    SettingTemplate.where(key: setting_template_key,
                          journal: journals)
  end

  def setting_template_key
    e = "Please implement setting_template_key for #{self.class.name}"
    raise NotImplementedError, e
  end

  def all_settings
    setting_templates.map do |st|
      {
        name: st.setting_name,
        value: setting(st.setting_name).value
      }
    end
  end

  # A Configurable can have many settings. A given setting can be accessed by
  # its name. Settings are lazily created when they are needed. To look up a
  # setting, a configurable has a setting_template_key that needs to be
  # defined first. Check `TaskTemplate` for an example. The defaults and
  # validations for a given type of setting are handled by the Setting class
  # itself. The SettingTemplate is just a simple mapping between a string key
  # and the Setting class name.
  def setting(name)
    settings.find_by(name: name) || begin
      t = setting_templates.find_by!(setting_name: name)

      setting_args = {
        name: t.setting_name,
        type: t.setting_klass,
        setting_template: t,
        value_type: t.value_type,
        owner: self
      }

      settings.create!(setting_args) do |setting|
        # due to some init/AR/meta issues in the original implementation :(
        setting.value = t.value
      end
    end
  end
end
