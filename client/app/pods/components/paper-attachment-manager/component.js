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

  task: null,
  paper: computed.reads('task.paper'),

  propTypes: {
    attachmentType: PropTypes.oneOf(['manuscript', 'sourcefile']).isRequired,
    errorMessage: PropTypes.string // overrides attachment manager errors
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
          s3Url: s3Url
        })
        .save();
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
