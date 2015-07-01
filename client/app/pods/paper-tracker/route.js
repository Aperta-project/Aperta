import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';
import Utils from 'tahi/services/utils';

export default Ember.Route.extend({
  model() {
    return RESTless.get('/api/paper_tracker');
  },

  setupController(controller, data) {
    let formattedData = Utils.deepCamelizeKeys(data.papers);
    formattedData.forEach(function(paper) {
      paper.submittedAt = new Date(paper.submittedAt);
    });

    controller.set('model', formattedData);
  }
});
