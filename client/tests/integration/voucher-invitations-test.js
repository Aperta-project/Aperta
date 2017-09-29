import Ember from 'ember';
import { test } from 'ember-qunit';
import { make, mockFindRecord } from 'ember-data-factory-guy';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

moduleForAcceptance('Integration: Voucher Invitations', {
  beforeEach: function () {
    return Ember.run(() => {
      $.mockjax({
        type: 'GET',
        url: '/api/journals',
        status: 200,
        responseText: {
          journals: []
        }
      });
    });
  }
});

test('Declined invitations are inactive and cannot be re-declined', function(assert) {
  let declined_invitation = make('voucher-invitation', { state: 'declined '});
  mockFindRecord('voucher-invitation').returns({ model: declined_invitation });
  visit(`/voucher_invitations/${declined_invitation.get('token')}`);
  return andThen(() => {
    assert.textPresent('.message', 'This invitation is no longer active');
  });
});
