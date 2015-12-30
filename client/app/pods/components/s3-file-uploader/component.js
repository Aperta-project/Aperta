import Ember from 'ember';

export default Ember.TextField.extend({
  type: 'file',
  name: 'file',
  multiple: false,
  filePath: null, // passed-in

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

    this.$().on('fileuploaddone', (e, data) => {
      // call action uploadFinished if it's defined
      if (this.attrs.uploadFinished) {
        // S3 will return XML with url
        let uploadedS3Url = $(data.result).find('Location')[0].textContent;
        uploadedS3Url = decodeURIComponent(uploadedS3Url);

        this.attrs.uploadFinished(uploadedS3Url);
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
