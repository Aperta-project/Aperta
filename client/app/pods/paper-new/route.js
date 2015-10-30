import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('paper', {
      journal: null,
      paperType: null,
      editable: true,
      body: ''
    });
  },

  setupController(controller) {
    this._super(...arguments);
    controller.set('journals', this.store.find('journal'));
  }
});
