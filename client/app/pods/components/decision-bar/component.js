import Ember from 'ember';

export default Ember.Component.extend({
  decision: null, // pass in an ember-data Decision

  // States:
  folded: true,

  classNames: ['decision-bar'],

  attachmentsForVersion: Ember.computed('attachmentSnapshots', 'decision',
  function() {
    let version = 'R' + this.get('decision.revisionNumber');
    return this.get('attachmentSnapshots').filterBy('versionString', version);
  }),

  actions: {
    fold() {
      this.set('folded', !this.get('folded'));
    }
  }
});
