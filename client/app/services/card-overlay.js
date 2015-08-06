import Ember from 'ember';

export default Ember.Service.extend({
  defaultBackground: 'overlay-background',
  _overlayBackground: null,
  overlayBackground: Ember.computed('_overlayBackground', {
    get() {
      return this.get('_overlayBackground') || this.get('defaultBackground');
    },
    set(key, value) {
      this.set('_overlayBackground', value);
      return value;
    }
  }),

  /*
   * Used by TaskController when closing the overlay.
   * Should be the same array you would pass to the
   * `transitionToRoute` method:
   * ['route.name.here', series of models or ids, {optionsHash}]
   */
  previousRouteOptions: null,

  /*
   * If coming from a screen with an expensive payload,
   * store the model here and pull it out in your `model` hook.
   * Please null out `cachedModel` after using it.
   */
  cachedModel: null
});
