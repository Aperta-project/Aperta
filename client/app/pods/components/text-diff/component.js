import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['text-diff'],

  // This is the text of the version being viewed (left dropdown)
  viewingText: null,

  // This is the text of the version we're comparing with (right dropdown)
  comparisonText: null,

  // This is the default if nothing else is set
  default: null,

  hasComparisonText: Ember.computed.notEmpty('comparisonText'),
  hasViewingText: Ember.computed.notEmpty('viewingText'),
  hasText: Ember.computed.or('hasComparisonText', 'hasViewingText'),

  chunks: Ember.computed('comparisonText', 'viewingText', function() {
    if (this.get('hasText')) {
      return this.diff();
    }
    else {
      [{value: this.get('default')}];
    }
  }),

  diff() {
    return JsDiff.diffSentences(
      this.get('comparisonText'),
      this.get('viewingText'));
  }
});
