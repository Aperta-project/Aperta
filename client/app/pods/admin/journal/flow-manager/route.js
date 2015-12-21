import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.find('role', params.role_id);
  },

  afterModel(role) {
    return this.store.find('flow', { role_id: role.get('id') });
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
