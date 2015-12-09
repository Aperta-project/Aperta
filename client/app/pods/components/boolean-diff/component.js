import Ember from 'ember';

export default Ember.Component.extend({
  viewingBool: null,
  comparisonBool: undefined,

  boolText(bool) {
    return bool ? 'Yes' : 'No';
  },

  viewingBoolText: Ember.computed('viewingBool', function() {
    return this.boolText(this.get('viewingBool'));
  }),

  comparisonBoolText: Ember.computed('comparisonBool', function() {
    return this.boolText(this.get('comparisonBool'));
  }),

  comparisonBoolDefined:
    Ember.computed('comparisonBool', function() {
      return this.get('comparisonBool') !== undefined;
  })
});
