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

  chunks: Ember.computed('comparisonText', 'viewingText', function() {
    if (this.get('hasComparisonText')) {
      return this.diff();
    } else {
      return [{value: this.get('viewingText') || this.get('default')}];
    }
  }),

  diff() {
    return JsDiff.diffSentences(
      String(this.get('comparisonText')),
      String(this.get('viewingText') || this.get('default')));
  }
});
