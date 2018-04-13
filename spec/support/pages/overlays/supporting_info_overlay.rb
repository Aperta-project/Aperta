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

require 'support/pages/card_overlay'

class SupportingInfoOverlay < CardOverlay
  def has_file?(file_name)
    have_xpath("//a[contains(@href, \"#{file_name}\"]")
  end

  def attach_supporting_information(file_name = 'yeti.jpg')
    upload_file(
      element_id: 'file_attachment',
      file_name: file_name,
      sentinel: -> { SupportingInformationFile.count }
    )
  end

  def attach_bad_supporting_information
    upload_file(
      element_id: 'file_attachment',
      file_name: 'bad_yeti.tiff',
      sentinel: -> { SupportingInformationFile.count }
    )
  end

  def edit_file_info
    find('.si-file-edit-icon').click
  end

  def save_file_info
    find('.si-file-save-edit-button').click
  end

  def file_label_input=(new_label)
    label = find('.si-file-label-field')
    label.set new_label
  end

  def file_category_dropdown=(new_category)
    power_select('.si-file-category-input', new_category)
  end

  def toggle_for_publication
    checkbox = find('.si-file-publishable-checkbox')
    checkbox.click
  end

  def error_message
    find('.si-file-actions .error-message').text
  end

  def file_error_message
    find('.si-file-error .error-message').text
  end

  def dismiss_file_error
    find('.si-file-error .acknowledge-error-button').click
  end

  def file_title
    find('.si-file-title').text
  end

  def file_caption
    find('.si-file-caption').text
  end

  def publishable_checkbox
    find(".publishable")
  end

  def upload_files
    click_button "Upload File"
  end

  def delete_file
    find('.si-file-delete-icon').click
    find('.si-file-delete-button').click
  end
end
