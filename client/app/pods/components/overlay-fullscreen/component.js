import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['overlay-x', 'overlay-x--fullscreen'],
  actions: {
    close() { this.attrs.close(); }
  }
});
