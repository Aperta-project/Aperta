import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

var PaperVersionsRoute = AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  afterModel(model) {
    return Ember.RSVP.all([
      model.get('tasks'),
      model.get('versionedTexts'),
      model.get('snapshots')]);
  },

  setupController(controller, model) {
    controller.set('model', model);
    controller.set('subRouteName', 'versions');
    if (controller.get('selectedVersion1')) {
      controller.set('viewingVersion', model.textForVersion(
        controller.get('selectedVersion1')
      ));
    } else {
      let latest = model.get('versionedTexts').objectAt(0);
      let fullVersion = latest.get('majorVersion') +
                        '.' +
                        latest.get('minorVersion');
      controller.set('selectedVersion1', fullVersion);
    }

    if (controller.get('selectedVersion2')) {
      controller.set('comparisonVersion', model.textForVersion(
        controller.get('selectedVersion2')
      ));
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
