import Ember from 'ember';
export default Ember.Controller.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),
  actions: {
    close() {
      const previous  = this.get('cardOverlayService.previousRouteOptions');
      const nextRoute = Ember.isEmpty(previous) ? ['dashboard'] : previous;
      this.transitionToRoute.apply(this, nextRoute);
    }
  }
});
