import Ember from 'ember';
import win from 'tahi/lib/window-location';

export default Ember.Namespace.create({
  initiate(paperId, downloadFormat, versionId) {
    const self = this;

    return Ember.$.ajax({
      url: `/api/paper_downloads/${paperId}`,
      data: {
        export_format: downloadFormat,
        versioned_text_id: versionId
      },
      success(data) {
        win.location(data.url);
      },
      error() {
        throw new Error('Could not download ' + downloadFormat);
      }
    });
  }
});
