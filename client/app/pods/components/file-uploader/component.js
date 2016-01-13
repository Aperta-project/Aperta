// Uses jQuery-File-Upload to upload files to s3
// https://github.com/blueimp/jQuery-File-Upload
// which adds this method to the jquery element:
// this.$().fileupload(params);
//
// Actions
// this needs to be used in concert with a component (like a task) that
// includes the mixin that contains the actions emitted:
// export default TaskComponent.extend(FileUploadMixin, {
//
//    the following actions are passed in and emitted:
//      error
//      done
//      start
//      uploadReady
//      progress
//      process
//      processingDone

import Ember from 'ember';

export default Ember.TextField.extend({
  type: 'file',
  name: 'file',
  multiple: false,
  accept: null,
  filePrefix: null,
  uploadImmediately: true,
  disabled: false,
  dataType: 'json',
  method: 'POST',
  railsMethod: 'POST',
  
  acceptedFileTypes: Ember.computed('accept', function(){
    let types = this.get('accept').replace(/\./g, '').replace(/,/g, '|');
    return new RegExp("(" + types + ")$", 'i');
  }),
  
  checkFileType: function(e, data) {
    var errorMessage, fileName;
    if (this.get('accept')) {
      fileName = data.originalFiles[0]['name'];
      if (fileName.length && !this.get('acceptedFileTypes').test(fileName)) {
        errorMessage = "Sorry! '" + data.originalFiles[0]['name'] + "' is not of an accepted file type";
        this.set('error', errorMessage);
        this.sendAction('error', errorMessage);
        return e.preventDefault();
      }
    }
  },
  setupUploader: (function() {
    var params, that, uploader;
    uploader = this.$();
    params = this.getProperties('dataType', 'method', 'acceptFileTypes');
    params.dataType = 'xml';

    // since we're not overriding the uploader's add method, we need to prevent
    // the form from autosubmitting before the s3 stuff has gone through first.
    params.autoUpload = false;
    params.previewMaxHeight = 90;
    params.previewMaxWidth = 300;

    // No matter how dumb this looks, it is necessary.
    that = this;

    // callback executes after successful upload to s3
    params.success = function(fileData) {
      var filename, location, requestMethod, resourceUrl;
      filename = this.files[0].name;

      // fileData is xml returned from s3
      location = $(fileData).find('Location').text().replace(/%2F/g, "/");
      resourceUrl = that.get('url');
      requestMethod = that.get('railsMethod');

      // I can't really tell what 'case' this is. Clearly it's when a
      // resourceUrl is not passed to the controller, which seems to mean
      // that the resource will appear on s3, but not be realayed back
      // to rails
      if (resourceUrl) { // tell rails server that upload to s3 finished
        return $.ajax({
          url: resourceUrl,
          dataType: 'json',
          type: requestMethod,
          data: Ember.merge({
            url: location
          }, that.get('dataParams')),
          success: function(data) {
            return that.sendAction('done', data, filename);
          }
        });
      // This seems to be thea case where nothing is posted back to rails
      // The done action is called, but it's not clear what should happen
      // differently at that point
      } else { // allow custom behavior when s3 upload is finished
        return that.sendAction('done', location, filename);
      }
    };
    uploader.fileupload(params);

    // called when file selected from dialog window
    uploader.on('fileuploadadd', (e, uploadData) => {
      var file, self;
      if (this.get('disabled')) {
        return;
      }
      Ember.run.bind(this, this.checkFileType);
      file = uploadData.files[0];
      self = this;
      return $.ajax({  // make get request to setup s3 keys for actual upload
        url: '/api/s3/request_policy',
        type: 'GET',
        dataType: 'json',
        data: {
          file_prefix: this.get('filePrefix'),
          content_type: file.type
        },
        success: function(data) {
          var uploadFunction;
          uploadData.url = data.url;
          uploadData.formData = {
            key: data.key + '/' + file.name,
            policy: data.policy,
            success_action_status: 201,
            'Content-Type': file.type,
            signature: data.signature,
            AWSAccessKeyId: data.access_key_id,
            acl: data.acl
          };
          uploadFunction = function() {
            return uploadData.process().done(function(data) {
              return self.sendAction('start', data, uploadData.submit());
            });
          };
          if (self.get('uploadImmediately')) {
            return uploadFunction();
          } else {
            return self.sendAction('uploadReady', uploadFunction);
          }
        }
      });
    });
    uploader.on('fileuploadprogress', (e, data) => {
      return this.sendAction('progress', data);
    });
    uploader.on('fileuploadprocessstart', (e, data) => {
        return this.sendAction('process', data);
    });
    uploader.on('fileuploadprocessalways', (e, data) => {
      return this.sendAction('processingDone', data.files[0]);
    });
    uploader.on('fileuploadfail', (e, data) => {
      return this.sendAction('error', data);
    });
  }).on('didInsertElement')
});
