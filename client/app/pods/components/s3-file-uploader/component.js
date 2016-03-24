import Ember from 'ember';

/**
 *  An input file that wraps jquery-file-upload plugin.
 *  This component calls the API requesting the parameters required
 *  for making a direct request to Amazon S3, it requires the filePath.
 *  You can sent functions as closure actions, that will hook the callbacks from
 *  jquery-file-upload
 *
 *  ## How to Use
 *
 *  In your template:
 *
 *  ```
 *  {{s3-file-uploader accept=accept
 *                  filePath=filePath
 *                  uploadProgress=(action "uploadProgress")
 *                  uploadFinished=(action "uploadFinished")
 *                  uploadFailed=(action "uploadFailed")
 *                  fileAdded=(action "fileAdded")}}
 *  ```
**/
export default Ember.Component.extend({
  attributeBindings: ['type', 'accept', 'multiple', 'name', 'disabled'],
  tagName: 'input',
  type: 'file',
  name: 'file',
  multiple: false,
  disabled: false,

  init() {
    this._super(...arguments);
    Ember.assert('Please provide filePath property', this.get('filePath'));
  },

  didInsertElement() {
    Ember.run.scheduleOnce('afterRender', this, this._setupFileUpload);
    this._super(...arguments);
  },

  _setupFileUpload() {
    this.$().fileupload({
      autoUpload: false,
      dataType: 'XML',
      method: 'POST'
    });

    this.$().on('fileuploadadd', (e, data) => {

      // call action fileAdded if it's defined
      if (this.attrs.fileAdded) {
        this.attrs.fileAdded(data.files[0]);
      }

      // get keys in order to make a successful request to S3
      const requestPayload = { file_path: this.get('filePath'),
                               file_name: data.files[0].name,
                               content_type: data.files[0].type };

      return $.getJSON('/api/s3/sign', requestPayload, (response) => {
        data.url = response.url;
        data.formData = response.formData;
        return data.process().done(() => {
          return data.submit();
        });
      });
    });

    this.$().on('fileuploadstart', (e, data) => {
      // call action uploadStarted if it's defined
      if (this.attrs.uploadStarted) {
        this.attrs.uploadStarted();
      }
    });

    this.$().on('fileuploadprogress', (e, data) => {
      // call action uploadProgress if it's defined
      if (this.attrs.uploadProgress) {
        this.attrs.uploadProgress(data);
      }
    });

    this.$().on('fileuploaddone', (e, data) => {
      // call action uploadFinished if it's defined
      if (this.attrs.uploadFinished) {
        // S3 will return XML with url
        let uploadedS3Url = $(data.result).find('Location')[0].textContent;
        uploadedS3Url = uploadedS3Url.replace(/%2F/g, '/');

        this.attrs.uploadFinished(uploadedS3Url, data);
      }
    });

    this.$().on('fileuploadfail', (e, data) => {
      // call action uploadFailed if it's defined
      if (this.attrs.uploadFailed) {
        this.attrs.uploadFailed(data.errorThrown);
      }
    });
  }
});
