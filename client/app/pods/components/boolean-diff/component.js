import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',
  viewingBool: null,
  comparisonBool: null,

  boolText(bool) {
    if(_.isUndefined(bool) || _.isNull(bool)) {
      // return value null or undefined value so that it can be sent through
      // to text-diff which will do the comparison correctly to determin
      // if value added or removed
      return bool;
    } else {
      return bool ? 'Yes' : 'No';
    }
  },

  viewingBoolText: Ember.computed('viewingBool', function() {
    return this.boolText(this.get('viewingBool'));
  }),

  comparisonBoolText: Ember.computed('comparisonBool', function() {
    return this.boolText(this.get('comparisonBool'));
  })
});
