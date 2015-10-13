import Ember from 'ember';

export default Ember.Component.extend({
  initialState: null,
  startEditingCallback: Ember.K,
  stopEditingCallback: Ember.K,
  editing: null,

  _setupEditingState: Ember.on('didInitAttrs', function() {
    this.set('editing', this.get('initialState'));
  }),

  actions: {
    startEditing() {
      this.set('editing', true);
      this.get('startEditingCallback')();
    },

    stopEditing() {
      this.set('editing', false);
      this.get('stopEditingCallback')();
    }
  }
});
