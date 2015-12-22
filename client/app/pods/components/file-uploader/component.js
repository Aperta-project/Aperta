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
var FileUploaderComponent;

FileUploaderComponent = Ember.TextField.extend({
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
  acceptedFileTypes: (function() {
    var types;
    types = this.get('accept').replace(/\./g, '').replace(/,/g, '|');
    return new RegExp("(" + types + ")$", 'i');
  }).property('accept'),
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
    params.autoUpload = false;
    params.previewMaxHeight = 90;
    params.previewMaxWidth = 300;
    that = this;
    params.success = function(fileData) {
      var filename, location, requestMethod, resourceUrl;
      filename = this.files[0].name;
      location = $(fileData).find('Location').text().replace(/%2F/g, "/");
      resourceUrl = that.get('url');
      requestMethod = that.get('railsMethod');
      if (resourceUrl && requestMethod) {
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
      } else {
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
      return $.ajax({
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

export default FileUploaderComponent;
