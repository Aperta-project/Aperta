import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  viewName: 'paper/index',
  controllerName: 'paper/index',
  templateName: 'paper/index',
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel(model) {
    return model.get('tasks');
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    controller.set('commentLooks', this.store.all('commentLook'));
    this.setFlagViewManuscriptManager(controller, model);
  },

  updateShowSubmissionProcess: function(){
    //setting query param to undefined doesn't trigger dependent comp props
    this.controller.notifyPropertyChange('showSubmissionProcess');
  }.on('deactivate'),

  actions: {
    viewCard(task) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.index', this.modelFor('paper')],
        overlayBackground: 'paper.index'
      });

      return this.transitionTo('paper.task', this.modelFor('paper'), task.id);
    }
  }
});
