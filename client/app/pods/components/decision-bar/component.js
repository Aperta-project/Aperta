import Ember from 'ember';
import SnapshotAttachment from 'tahi/models/snapshot/attachment';

export default Ember.Component.extend({
  decision: null, // pass in an ember-data Decision

  // States:
  folded: true,

  classNames: ['decision-bar'],

  attachmentsForVersion: Ember.computed(
    'attachmentSnapshots.@each.versionString', 'decision.revisionNumber',
  function() {
    let version = 'R' + this.get('decision.revisionNumber');
    let snapshots = this.get('attachmentSnapshots');
    if (snapshots) return snapshots.filterBy('versionString', version)
      .map(e => SnapshotAttachment.create({attachment: e.get('contents')}));
  }),

  actions: {
    fold() {
      this.set('folded', !this.get('folded'));
    }
  }
});
