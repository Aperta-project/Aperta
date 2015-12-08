import Ember from 'ember';

export default Ember.Component.extend({
  viewingBool: null,
  comparisonBool: null,

  boolText(bool) {
    return bool ? 'Yes' : 'No';
  },

  viewingBoolText: Ember.computed('viewingBool', function() {
    return this.boolText(this.get('viewingBool'));
  }),

  comparisonBoolText: Ember.computed('comparisonBool', function() {
    return this.boolText(this.get('comparisonBool'));
  }),

  // Silly javascript really delights in casting things to Bool. We
  // want an ACTUAL VALUE, not just null or undefined.
  comparisonBoolDefined: Ember.computed('comparisonBool', function() {
    return (this.get('comparisonBool') !== null &&
            this.get('comparisonBool') !== undefined);
  })
});
