/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/file-uploader',
  'Integration | Component | card content | file uploader',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.setProperties({
        actionStub: function() {},
        content: Ember.Object.create({
          ident: 'test',
          allowFileCaptions: true,
          allowMultipleUploads: true,
          label: 'Upload',
          text: 'Please upload a file',
          valueType: 'attachment'
        }),
        answer: Ember.Object.create({ value: null, attachments: [] })
      });
    }
  }
);

let template = hbs`{{card-content/file-uploader
                      answer=answer
                      content=content
                      disabled=disabled
                      preview=preview
                    }}`;

test(`shows an uploader with a button`, function(assert) {
  this.render(template);
  assert.textPresent(
    '.fileinput-button',
    'Upload',
    'The label displayed as the file upload button text'
  );

  this.set('disabled', true);
  assert.elementNotFound(
    'fileinput-button',
    'disabling will hide the button unless alwaysShowAddButton is set to true'
  );

  this.setProperties({ disabled: false, preview: true });
  assert.elementFound(
    '.button--disabled',
    'preview will also disable the button'
  );

  this.setProperties({ disabled: false, preview: false });
  this.set('content.allowMultipleUploads', false);
  this.set('answer.attachments', [{ filename: 'foo.txt', src: 'foo' }]);
  assert.elementNotFound(
    '.fileinput-button',
    `Doesn't show the button when multiple=false and there's an existing upload`
  );
});
