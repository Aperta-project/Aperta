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
    uploader.on('fileuploadadd', (function(_this) {
      return function(e, uploadData) {
        var file, self;
        if (_this.get('disabled')) {
          return;
        }
        Ember.run.bind(_this, _this.checkFileType);
        file = uploadData.files[0];
        self = _this;
        return $.ajax({
          url: "/api/s3/request_policy",
          type: 'GET',
          dataType: 'json',
          data: {
            file_prefix: _this.get('filePrefix'),
            content_type: file.type
          },
          success: function(data) {
            var uploadFunction;
            uploadData.url = data.url;
            uploadData.formData = {
              key: data.key + "/" + file.name,
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
      };
    })(this));
    uploader.on('fileuploadprogress', (function(_this) {
      return function(e, data) {
        return _this.sendAction('progress', data);
      };
    })(this));
    uploader.on('fileuploadprocessstart', (function(_this) {
      return function(e, data) {
        return _this.sendAction('process', data);
      };
    })(this));
    uploader.on('fileuploadprocessalways', (function(_this) {
      return function(e, data) {
        return _this.sendAction('processingDone', data.files[0]);
      };
    })(this));
    return uploader.on('fileuploadfail', (function(_this) {
      return function(e, data) {
        return _this.sendAction('error', data);
      };
    })(this));
  }).on('didInsertElement')
});

export default FileUploaderComponent;
