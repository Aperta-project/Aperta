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

require 'support/pages/fragments/phase_fragment'
require 'support/pages/page'

class ManuscriptManagerTemplatePage < Page
  text_assertions :paper_type, ".paper-type-name"

  def self.visit(journal)
    page.visit "/admin/mmt/journals/#{journal.to_param}/manuscript_manager_templates"
    new
  end

  def phases
    expect(page).to have_css('.column h2')
    all('.column h2').map(&:text)
  end

  def has_phase_names?(*phases)
    phases.each do |p_name|
      expect(page).to have_css('.column h2', text: p_name)
    end
  end

  def find_phase(phase_name)
    PhaseFragment.new(
      find('.column h2', text: phase_name).find(:xpath, '../../..'))
  end

  def add_new_template
    click_link "Add New Template"
  end

  def paper_type
    find(".paper-type-name")
  end

  def paper_type=(type)
    find(".paper-type-name").click
    find(".edit-paper-type-field").set(type)
  end

  def save
    find(".paper-type-save-button").click
  end
end
