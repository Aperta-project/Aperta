import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  afterModel(model) {
    return model.get('tasks');
  },

  setupController(controller, model) {
    this._super(...arguments);

    if (this.currentUser) {
      const url = '/api/papers/' + model.get('id') + '/manuscript_manager';
      return this.get('restless')
                 .authorize(controller, url, 'canViewManuscriptManager');
    }
  },

  updateShowSubmissionProcess: Ember.on('deactivate', function() {
    //setting query param to undefined doesn't trigger dependent comp props
    this.controller.notifyPropertyChange('showSubmissionProcess');
  })
});
