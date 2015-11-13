import Ember from 'ember';
import ENV from 'tahi/config/environment';
import AuthorizedRoute from 'tahi/routes/authorized';

var PaperVersionsRoute = AuthorizedRoute.extend({
  viewName: 'paper/versions',
  controllerName: 'paper/versions',
  templateName: 'paper/versions',
  cardOverlayService: Ember.inject.service('card-overlay'),
  restless: Ember.inject.service('restless'),

  model: function() {
    return this.modelFor('paper');
  },

  afterModel: function(model) {
    return Ember.RSVP.all([
      model.get('tasks'),
      model.get('versionedTexts')]);
  },

  setupController: function(controller, model) {
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
        "/api/papers/#{model.get('id')}/manuscript_manager",
        'canViewManuscriptManager'
      );
    }
  },

  actions: {
    viewVersionedCard: function(task, majorVersion, minorVersion) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.versions', this.modelFor('paper'), {
          queryParams: {
            majorVersion: majorVersion,
            minorVersion: minorVersion
          }
        }],
        overlayBackground: 'paper.versions'
      });

      this.transitionTo(
        'paper.task.version',
        this.modelFor('paper'),
        task.id,
        {
          queryParams: {
            majorVersion: majorVersion,
            minorVersion: minorVersion
          }
        });
    },

    exitVersions: function() {
      this.transitionTo('paper.index', this.modelFor('paper'));
    }
  }
});

export default PaperVersionsRoute;
