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
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';

moduleForComponent('attachment-link', 'Integration | Component | Attachment Link', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);

    this.setProperties({
      draft: 'draft'
    });

    let attachment = FactoryGuy.make('decision-attachment');
    this.set('attachment', attachment);
  }
});

var template = hbs`
      {{attachment-link accept=accept
                        attachment=attachment
                        draft=draft
                        filePath=filePath
                        hasCaption=hasCaption
                        caption=attachment.caption
                        captionChanged=attrs.captionChanged
                        cancelUpload=attrs.cancelUpload
                        deleteFile=attrs.deleteFile
                        noteChanged=attrs.noteChanged
                        uploadFinished=attrs.updateAttachment
                        progress=uploadProgress
                        start=fileAdded
                        multiple=multiple
                        disabled=disabled }}
    `;

test('it renders the file uploader on the attachment-link', function(assert) {
  this.render(template);
  assert.elementFound('input.update-attachment');
});

test('when the user clicks on Replace, the file uploader should be triggered', function(assert) {
  assert.expect(1);

  this.render(template);
  this.$('.update-attachment').on('click', () => { assert.ok(true, 'action invoked'); });
  this.$('.replace-attachment').click();
});
