import Ember from 'ember';

export default Ember.Route.extend({
  restless: Ember.inject.service('restless'),

  model() {
    return this.get('restless').get('/api/paper_tracker').then((data)=> {
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
