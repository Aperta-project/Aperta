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

import Ember from 'ember';
const { computed } = Ember;
import { PropTypes } from 'ember-prop-types';
/**
 * paper-attachment-manager wires up attachment-manager so that it can
 * deal with the paper's file and sourcefile.
 */

const attachmentInfo = {
  manuscript: {
    filePath: 'paper/manuscript',
    attachmentClass: 'manuscript-attachment',
    attachmentBinding: 'paper.file'
  },
  sourcefile: {
    filePath: 'paper/source',
    attachmentClass: 'sourcefile-attachment',
    attachmentBinding: 'paper.sourcefile'
  }
};

export default Ember.Component.extend({
  classNames: ['card-content-file-uploader'],

  store: Ember.inject.service(),
  cardEvent: Ember.inject.service(),

  task: null,
  paper: computed.reads('task.paper'),

  propTypes: {
    attachmentType: PropTypes.oneOf(['manuscript', 'sourcefile']).isRequired,
    errorMessage: PropTypes.oneOfType([
      PropTypes.null,
      PropTypes.string // overrides attachment manager errors
    ])
  },

  // Do not propagate to parent component as this component is in charge of
  // saving itself (otherwise the parent component may issue another attempt to
  // save the attachment). Remember that 'change' intercepts the change event
  // from any child DOM element.
  change: function() {
    return false;
  },

  filePath: Ember.computed('attachmentType', function() {
    return attachmentInfo[this.get('attachmentType')].filePath;
  }),

  attachments: Ember.computed(
    'attachmentType',
    'paper.file',
    'paper.sourcefile',
    function() {
      let attachment;
      if (this.get('attachmentType') === 'manuscript') {
        attachment = this.get('paper.file');
      } else {
        attachment = this.get('paper.sourcefile');
      }

      if (attachment) {
        // technically paper attachments don't belong to a task but this is
        // needed for the attachment adapter to find the correct url
        attachment.set('task', this.get('task'));
      }
      return [attachment].compact();
    }
  ),

  actions: {
    createFile(s3Url, file) {
      Ember.assert(s3Url, 'Must provide an s3Url');
      Ember.assert(file, 'Must provide a file');
      const store = this.get('store');
      let attachmentClass =
        attachmentInfo[this.get('attachmentType')].attachmentClass;
      store
        .createRecord(attachmentClass, {
          task: this.get('task'),
          s3Url: s3Url,
          paper: this.get('task.paper')
        })
        .save().then(() => {
          this.get('cardEvent').trigger('onPaperFileUploaded', this.get('attachmentType'));
        });
    },

    updateFile(s3Url, file) {
      Ember.assert(s3Url, 'Must provide an s3Url');
      Ember.assert(file, 'Must provide a file');
      let attachmentBinding =
        attachmentInfo[this.get('attachmentType')].attachmentBinding;
      let manuscript = this.get(attachmentBinding);
      manuscript.setProperties({
        task: this.get('task'),
        s3Url: s3Url
      });
      manuscript.save();
    }
  }
});
