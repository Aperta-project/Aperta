import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';
import Utils from 'tahi/services/utils';

export default Ember.Route.extend({
  model() {
    return RESTless.get('/api/paper_tracker').then((data)=> {
      this.store.pushPayload('paper', data);
      let paperIds = data.papers.mapBy('id');

      return this.store.all('paper').filter(function(p) {
        if(paperIds.contains( parseInt(p.get('id')) )) {
          return p;
        }
      });
    });
  },

  setupController(controller, model) {
    this.store.find('comment-look');
    this._super(controller, model);
  }
});
