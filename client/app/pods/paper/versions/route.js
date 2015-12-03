import Ember from 'ember';
import ENV from 'tahi/config/environment';
import AuthorizedRoute from 'tahi/routes/authorized';

var PaperVersionsRoute = AuthorizedRoute.extend({
  viewName: 'paper/versions',
  controllerName: 'paper/versions',
  templateName: 'paper/versions',
  cardOverlayService: Ember.inject.service('card-overlay'),

  model: function() {
    return this.modelFor('paper');
  },

  afterModel: function(model) {
    return Ember.RSVP.all([
      model.get('tasks'),
      model.get('versionedTexts')]);
  },

  setupController: function(controller, model) {
    this._super(controller, model);

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

    this.setFlagViewManuscriptManager(controller, model);
  },

  actions: {
    viewVersionedCard: function(task, selectedVersion1, selectedVersion2) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.versions', this.modelFor('paper'), {
          queryParams: {
            selectedVersion1: selectedVersion1,
            selectedVersion2: selectedVersion2
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
            selectedVersion1: selectedVersion1,
            selectedVersion2: selectedVersion2
          }
        });
    },

    exitVersions: function() {
      this.transitionTo('paper.index', this.modelFor('paper'));
    }
  }
});

export default PaperVersionsRoute;
