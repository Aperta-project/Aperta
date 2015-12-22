import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.find('oldRole', params.old_role_id);
  },

  afterModel(oldRole) {
    return this.store.find('flow', { old_role_id: oldRole.get('id') });
  },

  setupController(controller, model) {
    controller.setProperties({
      model: model,
      commentLooks: this.store.all('comment-look'),
      journal: this.modelFor('admin.journal'),
      journalTaskTypes: this.store.all('journal-task-type')
    });
  },

  renderTemplate() {
    this._super();
    this.render('flow-manager-buttons', {
      outlet: 'controlBarButtons',
      template: 'journal'
    });
  }
});
