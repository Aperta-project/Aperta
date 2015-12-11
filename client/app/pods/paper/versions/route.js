import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

var PaperVersionsRoute = AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  afterModel(model) {
    return Ember.RSVP.all([
      model.get('tasks'),
      model.get('versionedTexts')]);
  },

  setupController(controller, model) {
    controller.set('model', model);
    controller.set('subRouteName', 'versions');
    if (!(controller.get('majorVersion') && controller.get('minorVersion'))) {
      let latest = model.get('versionedTexts').objectAt(0);
      controller.set('majorVersion', latest.get('majorVersion'));
      controller.set('minorVersion', latest.get('minorVersion'));
    } else {
      controller.set('viewingVersion', model.textForVersion(
        controller.get('majorVersion'),
        controller.get('minorVersion')
      ));
    }

    if (this.currentUser) {
      this.get('restless').authorize(
        controller,
        `/api/papers/#{model.get('id')}/manuscript_manager`,
        'canViewManuscriptManager'
      );
    }
  },

  actions: {
    exitVersions() {
      this.transitionTo('paper.index', this.modelFor('paper'));
    },

    // Required until Ember has routable components.
    // We need to cleanup because controllers are singletons
    // and are not torn down:

    willTransition() {
      this.controllerFor('paper.versions').setProperties({
        taskToDisplay: null,
        showTaskOverlay: false
      });
    }
  }
});

export default PaperVersionsRoute;
