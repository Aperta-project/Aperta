import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';

export default Ember.Mixin.create({
  _initFileUpload: function() {
    return this.set('uploads', []);
  }.on('init'),

  uploads: null,
  isUploading: Ember.computed.notEmpty('uploads'),

  unloadUploads(data, filename) {
    let uploads = this.get('uploads');
    let newUpload = uploads.findBy('file.name', filename);
    uploads.removeObject(newUpload);
  },

  uploadStarted(data, fileUploadXHR) {
    let file = data.files[0];
    let filename = file.name;

    this.get('uploads').pushObject(FileUpload.create({
      file: file,
      xhr: fileUploadXHR
    }));

    $(window).on('beforeunload.cancelUploads.' + filename, function() {
      return 'You are uploading, are you sure you want to abort uploading?';
    });
  },

  uploadProgress(data) {
    let currentUpload = this.get('uploads').findBy('file', data.files[0]);
    if (!currentUpload) { return; }

    currentUpload.setProperties({
      dataLoaded: data.loaded,
      dataTotal: data.total
    });
  },

  uploadFinished(data, filename) {
    $(window).off('beforeunload.cancelUploads.' + filename);

    var key = Object.keys(data || {})[0];
    if ( (key && data[key]) || data[key] === [] ) {
      $('.upload-preview-filename').text('Upload Complete!');

      Ember.run.later(this, ()=> {
        $('.progress').fadeOut(()=>{
          this.unloadUploads(data, filename);
        });
      }, 2000);
    } else {
      this.unloadUploads(data, filename);
    }
  },

  cancelUploads() {
    this.get('uploads').invoke('abort');
    this.set('uploads', []);
    return $(window).off('beforeunload.cancelUploads');
  },

  actions: {
    uploadProgress(data) { this.uploadProgress(data); },
    cancelUploads()      { this.cancelUploads(); },
    uploadFinished(data, filename)     { this.uploadFinished(data, filename); },
    uploadStarted(data, fileUploadXHR) { this.uploadStarted(data, fileUploadXHR); }
  }
});
