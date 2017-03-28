import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';

export default Ember.Component.extend({
  isProcessing: Ember.computed.equal('attachment.status', 'processing'),

  fileTypeClass: Ember.computed('attachment.file', function(){
    return fontAwesomeFiletypeClass(this.get('attachment.file'));
  }),

  actions: {
    deleteFile() {
      if (this.attrs.deleteFile) {
        this.attrs.deleteFile(this.get('attachment'));
      }
    },

    cancelUpload() {
      this.set('isCanceled', true);
      this.get('cancelUpload')(this.get('attachment'));
    }
  }
});
