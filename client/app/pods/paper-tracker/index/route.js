import Ember from 'ember';

export default Ember.Route.extend({
  restless: Ember.inject.service('restless'),

  queryParams: {
    page: {
      refreshModel: true
    },
  },

  model(params) {
    return this.get('restless').get('/api/paper_tracker', params).then((data)=> {
      this.prepMetaData(data);
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
    this.setControllerData(controller);
    this._super(controller, model);
  },

  metaData: null, // comes in payload, must be plucked for use in setupController

  prepMetaData(data) {
    if (data.meta) {
      this.set('metaData', data.meta);
      delete data.meta; // or pushPayload craps
    }
  },

  setControllerData(controller) {
    controller.set('page', this.get('metaData.page'));
    controller.set('totalCount', this.get('metaData.totalCount'));
    controller.set('perPage', this.get('metaData.perPage'));
  },
});
