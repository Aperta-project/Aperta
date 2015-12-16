import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.find('task', params.task_id);
  },

  afterModel(model) {
    return model.get('snapshots');
  },
});
