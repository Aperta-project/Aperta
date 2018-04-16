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

module DataTransformation
  # Swaps fieldset card contents (which are not remove) with display-children
  # with the field-set custom class
  class ReplaceFieldSetCardContentTypes < Base
    counter :field_set_card_content_found

    def transform
      CardContent.where(content_type: 'field-set').each do |cc|
        increment_counter(:field_set_card_content_found)
        log("Migrating card content id: #{cc.id})")
        cc.update!(content_type: 'display-children', custom_class: 'card-content-field-set')
      end
      fieldset_cc = CardContent.where(content_type: 'field-set')
      assert(
        fieldset_cc.empty?,
        "#{fieldset_cc} field-set card contents still present!"
      )
    end
  end
end
