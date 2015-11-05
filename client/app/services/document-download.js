import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.Namespace.create({
  initiate: function(paperId, downloadFormat) {
    let self = this;

    self.paperId = paperId;
    self.downloadFormat = downloadFormat;

    return Ember.$.ajax({
      url: '/api/papers/' + self.paperId + '/export',
      data: {
        format: self.downloadFormat
      },
      success(data) {
        let jobId = data['id'];
        return self.checkJobState(jobId);
      },
      error() {
        throw new Error('Could not download ' + self.downloadFormat);
      }
    });
  },

  checkJobState: function(jobId) {
    let timeout = 2000;
    let self    = this;

    return Ember.$.ajax({
      url: '/api/papers/' + self.paperId + '/status/' + jobId,
      success(data) {
        let job = data['job'];
        if (job.state === 'completed') {
          let file = job.outputs.findBy('file_type', self.downloadFormat);
          if (file) { Utils.windowLocation(file.url); }
        } else if (job.state === 'errored') {
          alert('The download failed');
        } else {
          setTimeout(()=> {
            self.checkJobState(jobId);
          }, timeout);
        }
      }
    });
  }
});
