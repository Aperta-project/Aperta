import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.modelFor('admin.cc.card').get('cardVersions');
  }
});
