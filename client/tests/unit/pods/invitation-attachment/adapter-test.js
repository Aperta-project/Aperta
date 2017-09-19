import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

moduleFor('adapter:invitation-attachment', 'Unit | Adapter | invitation attachment');

test('findRecord returns a hollow promise if it doesnt belongTo anything', function(assert) {
  assert.expect(1);
  const invitationAttachmentId = 1;
  let adapter = this.subject();
  let snapshot = Ember.Object.create();
  snapshot.belongsTo = function() { return null; };
  adapter.findRecord(null, null, invitationAttachmentId, snapshot).then((data) => {
    assert.equal(data['invitation-attachment'].id, invitationAttachmentId);
  });
});
