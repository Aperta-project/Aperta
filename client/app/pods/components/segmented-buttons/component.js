import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['segmented-buttons'],

  selectedValue: null,

  valueSelected: function(value) {
    this.sendAction('action', value);
  }
});
