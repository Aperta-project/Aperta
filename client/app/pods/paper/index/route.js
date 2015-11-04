import Ember from 'ember';
import ENV from 'tahi/config/environment';
import AuthorizedRoute from 'tahi/routes/authorized';
var PaperIndexRoute;

PaperIndexRoute = AuthorizedRoute.extend({
  viewName: 'paper/index',
  controllerName: 'paper/index',
  templateName: 'paper/index',
  cardOverlayService: Ember.inject.service('card-overlay'),
  restless: Ember.inject.service('restless'),
  fromSubmitOverlay: false,

  model: function() {
    var paper, taskLoad;
    paper = this.modelFor('paper');
    taskLoad = new Ember.RSVP.Promise(function(resolve, reject) {
      return paper.get('tasks').then(function(tasks) {
        return resolve(paper);
      });
    });
    return Ember.RSVP.all([taskLoad]).then(function() {
      return paper;
    });
  },
  afterModel: function(model) {
    return model.get('tasks');
  },

  setupController: function(controller, model) {
    controller.set('model', model);
    controller.set('commentLooks', this.store.all('commentLook'));
    if (this.currentUser) {
      return this.get('restless').authorize(controller, "/api/papers/" + (model.get('id')) + "/manuscript_manager", 'canViewManuscriptManager');
    }
  },

  updateShowSubmissionProcess: function(){
    //setting query param to undefined doesn't trigger dependent comp props
    this.controller.notifyPropertyChange('showSubmissionProcess');
  }.on('deactivate'),

  actions: {
    viewCard: function(task) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.index', this.modelFor('paper')],
        overlayBackground: 'paper.index'
      });
      return this.transitionTo('paper.task', this.modelFor('paper'), task.id);
    },
    showConfirmSubmitOverlay: function() {
      this.controllerFor('overlays/paper-submit').set('model', this.modelFor('paper'));
      this.send('openOverlay', {
        template: 'overlays/paper-submit',
        controller: 'overlays/paper-submit'
      });
      return this.set('fromSubmitOverlay', true);
    }
  }
});

export default PaperIndexRoute;
