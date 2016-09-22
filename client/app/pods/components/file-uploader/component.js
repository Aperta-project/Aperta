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
import checkType, { filetypeRegex } from 'tahi/lib/file-upload/check-filetypes';

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

  acceptFileTypes: Ember.computed('accept', function(){
    if (!this.get('accept')) { return null; }
    return filetypeRegex(this.get('accept'));
  }),

  // get keys in order to make a successful request to S3
  getS3Credentials(fileName, contentType) {
    let requestPayload = {
      file_path: this.get('filePrefix'),
      file_name: fileName,
      content_type: contentType
    };

    return Ember.$.getJSON('/api/s3/sign', requestPayload);
  },

  setupUploader: (function() {
    let uploader = this.$();
    let params = this.getProperties('dataType', 'method', 'acceptFileTypes');
    params.dataType = 'xml';

    // since we're not overriding the uploader's add method, we need to prevent
    // the form from autosubmitting before the s3 stuff has gone through first.
    params.autoUpload = false;
    params.previewMaxHeight = 90;
    params.previewMaxWidth = 300;

    uploader.fileupload(params);

    // called when file selected from dialog window
    uploader.on('fileuploadadd', (e, uploadData) => {
      if (this.get('disabled')) { return; }

      let file = uploadData.files[0];
      let fileName = file.name;
      let acceptedFileTypes = this.get('accept');
      let {error, msg} = checkType(fileName, acceptedFileTypes);

      if (error) {
        this.sendAction('addingFileFailed', msg, {fileName, acceptedFileTypes});
        return;
      }

      let self = this;

      let contentType = file.type;
      this.getS3Credentials(fileName, contentType).then(({url, formData}) => {
        uploadData.url = url;
        uploadData.formData = formData;

        let uploadFunction = function() {
          uploadData.process().done(function(data) {
            self.sendAction('start', data, uploadData.submit());
          });
        };

        if (self.get('uploadImmediately')) {
          uploadFunction();
        } else {
          self.sendAction('uploadReady', uploadFunction);
        }
      });

    });

    uploader.on('fileuploaddone', (e, fileData) => {
      let filename = fileData.files[0].name;

      // fileData is xml returned from s3
      let uploadedS3Url = $(fileData.result)
        .find('Location')[0]
        .textContent
        .replace(/%2F/g, '/');
      let resourceUrl = this.get('url');
      let requestMethod = this.get('railsMethod');

      // file-uploader will post data to the rails server itself if it's provided
      // with a `resourceUrl`.  This is in contrast to the s3-file-uploader, which
      // sends an action once the upload is complete.
      if (resourceUrl) { // tell rails server that upload to s3 finished
        let postData = Ember.merge(
          {
            url: uploadedS3Url,
            filename: filename
          } , this.get('dataParams')
        );
        $.ajax({
          url: resourceUrl,
          dataType: 'json',
          type: requestMethod,
          data: postData
        }).then((data) => {
          this.sendAction('done', data, filename);
        });
      } else {
      // without a resourceUrl pass the data up and allow the caller to
      // decide what to do with it.
        this.sendAction('done', location, filename);
      }
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
