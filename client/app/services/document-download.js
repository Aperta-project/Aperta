import Ember from 'ember';
import win from 'tahi/lib/window-location';

export default Ember.Namespace.create({
  initiate(paperId, downloadFormat, versionId) {
    const self = this;

    return Ember.$.ajax({
      url: `/api/papers/${paperId}/export`,
      data: {
        export_format: downloadFormat,
        versioned_text_id: versionId
      },
      success(data) {
        // Returns a url to check later.
        self.checkJobState(data.url);
      },
      error() {
        throw new Error('Could not download ' + downloadFormat);
      }
    });
  },

  checkJobState(url) {
    const self = this;
    const timeout = 2000;

    return Ember.$.ajax({
      url: url,
      statusCode: {
        200: (data)=>{
          // Done, download the results..
          win.location(data.url);
        },
        202: ()=>{
          // Still working, try again later.
          setTimeout(()=> {
            self.checkJobState(url);
          }, timeout);
        },
        500: ()=>{
          alert('The download failed');
        }
      }
    });
  }
});
