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

module RichTextEditorHelpers
  def get_rich_text(editor:)
    instance = editor_instance(editor)
    page.evaluate_script("#{instance}.getContent()")
  end

  def set_rich_text(editor:, text:)
    instance = editor_instance(editor)
    page.execute_script("#{instance}.setContent(#{text.to_json})")
    page.execute_script("#{instance}.target.triggerSave()")
  end

  def wait_for_editors(timeout: Capybara.default_max_wait_time, count: 1)
    Timeout.timeout(timeout) do
      sleep 0.5
      loop until page.evaluate_script("$('iframe').length").to_i >= count
    end
  end

  def editor_instance(name)
    "tinymce.editors.#{editor_id(name)}"
  end

  def within_editor_iframe(name)
    page.within_frame("#{editor_id(name)}_ifr") do
      yield
    end
  end

  def editor_id(name)
    selector = ".rich-text-editor[data-editor='#{name}']"
    find_editor_id = "$(\"#{selector}\").find('iframe').contents().find('body').data('id')"
    id = page.evaluate_script(find_editor_id)
    throw "missing editor id: #{name}" if id.blank?
    id
  end
end
