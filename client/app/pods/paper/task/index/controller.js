import Ember from 'ember';
import Participants from 'tahi/mixins/controllers/participants';

export default Ember.Controller.extend(Participants, {
  cardOverlayService: Ember.inject.service('card-overlay'),

  actions: {
    close() {
      const previous  = this.get('cardOverlayService.previousRouteOptions');
      const nextRoute = Ember.isEmpty(previous) ? ['dashboard'] : previous;
      this.transitionToRoute.apply(this, nextRoute);
    }
  }
});
