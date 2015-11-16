import Ember from 'ember';

export default Ember.Component.extend({
  to: 'overlay-drop-zone',
  visible: false,
  outAnimationComplete: null,

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must provide an outAnimationComplete action to OverlayBaseComponent',
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );
  }
});
