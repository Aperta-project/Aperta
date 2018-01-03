import {
  moduleFor,
  test
} from 'ember-qunit';

moduleFor('component:participant-selector', 'Unit | Component | participant selector', {
  integration: true,
  beforeEach() {
    this.subject({
      currentParticipants: [],
      onRemove: function() {},
      onSelect: function() {},
      searchStarted: function() {},
      searchFinished: function() {}
    });
  }
});

test('participantUrl defaults to the filtered users endpoint for the given paperId', function(assert) {
  this.subject().paperId = 10;
  assert.equal(this.subject().get('participantUrl'), '/api/filtered_users/users/10');
});

test('participantUrl can be overwritten by passing in url', function(assert) {
  this.subject().url = 'foo';
  assert.equal(this.subject().get('participantUrl'), 'foo');
});
