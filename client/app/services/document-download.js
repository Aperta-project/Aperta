import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.Namespace.create({
  initiate: function(paperId, downloadFormat) {
    let self = this;

    self.paperId = paperId;
    self.downloadFormat = downloadFormat;

    return Ember.$.ajax({
      url: `/api/papers/${self.paperId}/export`,
      data: {
        export_format: self.downloadFormat
      },
      success: (data)=> {
        // Returns a url to check later.
        self.checkJobState(data.url);
      },
      error() {
        throw new Error('Could not download ' + self.downloadFormat);
      }
    });
  },

  checkJobState: function(url) {
    let self = this;
    let timeout = 2000;

    return Ember.$.ajax({
      url: url,
      statusCode: {
        200: (data)=>{
          // Done, download the results..
          Utils.windowLocation(data.url);
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
