import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';
import Utils from 'tahi/services/utils';

export default Ember.Route.extend({
  model() {
    return this.getData();
  },

  setupController(controller, data) {
    controller.set('model', this.formatPaperPayload(data.papers));
  },


  getData() {
    let controller    = this.controllerFor('paper-tracker.index');
    let preloadedData = controller.get('model');

    // Data has not been loaded previously
    if(Ember.isEmpty(preloadedData)) {
      return RESTless.get('/api/paper_tracker');
    }

    // Data was loaded previously, return old data and background refresh
    RESTless.get('/api/paper_tracker').then((newData)=> {
      controller.set('model', this.formatPaperPayload(newData.papers));
    });

    return { papers: preloadedData };
  },

  formatPaperPayload(payload) {
    return Utils.deepCamelizeKeys(payload).map(function(paper) {
      paper.submittedAt = new Date(paper.submittedAt);
      return paper;
    });
  }
});
