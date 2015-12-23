import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';

export default Ember.Mixin.create({
  _initFileUpload: Ember.on('init', function() {
    return this.set('uploads', []);
  }),

  uploads: null, // apparently meant to track uploads currently uploading
  isUploading: Ember.computed.notEmpty('uploads'),

  removeUpload(filename) {
    this.get('uploads').removeObject(
     this.findUploadByFilename(filename)
    );
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
    let currentUpload = this.findUploadByFilename(data.files[0].name);

    if (!currentUpload) { return; }

    currentUpload.setProperties({
      dataLoaded: data.loaded,
      dataTotal: data.total
    });
  },

  uploadFinished(data, filename) {
    let UIWait = 2000; // ms
    $(window).off('beforeunload.cancelUploads.' + filename);

    // what?
    let key = Object.keys(data || {})[0];
    if ( (key && data[key]) || key && data[key] === [] ) {
      // TODO: DOM manipulation in mixin? This is used by controllers too
      $('.upload-preview-filename').text('Upload Complete!');
      Ember.run.later(this, ()=> {
         $('.progress').addClass('upload-complete');
      });
      Ember.run.later(this, ()=> {
        $('.progress').fadeOut(()=>{
          this.unloadUploads(data, filename);
        });
      }, 2000);
    } else {
      this.unloadUploads(data, filename);
    }

    setTimeout(() => { this.removeUpload(filename); }, UIWait);
  },

  findUploadByFilename(filename) {
    return _.find(this.get('uploads'), function(upload){
      return upload.get('file.name') === filename;
    });
  },

  cancelUploads() {
    this.get('uploads').invoke('abort');
    this.set('uploads', []);
    return $(window).off('beforeunload.cancelUploads');
  },

  actions: {
    uploadProgress(data) { this.uploadProgress(data); },
    cancelUploads() { this.cancelUploads(); },
    uploadFinished(data, filename) { this.uploadFinished(data, filename); },
    uploadStarted(data, fileUploadXHR) {
      this.uploadStarted(data, fileUploadXHR);
    },
  }
});
