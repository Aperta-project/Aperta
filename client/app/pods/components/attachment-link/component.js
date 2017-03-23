import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';

export default Ember.Component.extend({
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
    },


    captionChanged() {
      if (this.attrs.captionChanged) {
        this.attrs.captionChanged(this.get('caption'), this.get('attachment'));
      }
    },

    fileAdded(file){
      this.set('fileUpload', FileUpload.create({ file: file }));
    },

    triggerFileSelection() {
      this.$().find('input').click();
    },

    uploadProgress(data) {
      this.get('fileUpload').setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadFinished(s3Url){
      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url,
                                  this.get('fileUpload.file'),
                                  this.get('attachment'));
      }
      this.set('fileUpload', null);
    },

    uploadFailed(reason){
      throw new Ember.Error(`Upload from browser to s3 failed: ${reason}`);
    }
  }
});
