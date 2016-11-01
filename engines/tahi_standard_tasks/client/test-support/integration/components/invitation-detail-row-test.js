import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';

moduleForComponent('invitation-detail-row', 'Integration | Component | invitation detail row', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    this.set('update-date', new Date('January 01, 2016'));
    this.set('invitation', make('invitation', {
      declineReason: null,
      declined: false,
      email: 'jane@example.com',
      invitee: { fullName: 'Jane McEdits' },
      reviewerSuggestions: null,
      state: 'pending',
      title: 'Awesome Paper!',
      updatedAt: this.get('update-date')
    }));
  }
});

let template = hbs`{{invitation-detail-row
                      invitation=invitation
                      uiState='closed'}}`;

test('displays invitation information if invitation.invited is true', function(assert){
  this.set('invitation.state', 'invited');
  this.set('invitation.invitedAt', this.get('update-date'));
  this.render(template);

  assert.textPresent('.invitation-item-status',
                     `Invited ${moment(this.get('update-date')).format('MMM D, YYYY')}`);
});

test('displays invitee name and email when present', function(assert){
  this.render(template);

  assert.textPresent('.invitation-item-full-name', 'Jane McEdits');
  assert.textPresent('.invitation-item-full-name', '<jane@example.com>');
});

test('displays invitation email when no invitee present', function(assert){
  this.set('invitation.invitee', null);
  this.render(template);

  assert.textNotPresent('.invitation-item-full-name', 'Jane McEdits');
  assert.textPresent('.invitation-item-full-name', 'jane@example.com');
});


// header buttons

let openTemplate = hbs`{{invitation-detail-row invitation=invitation
                                               currentRound=currentRound
                                               uiState=uiState}}`;

test('the row is in the closed state, in the current round', function(assert) {
  this.setProperties({
    'invitation.state': 'pending',
    currentRound: true,
    uiState: 'closed'
  });
  this.render(openTemplate);
  assert.elementNotFound('.invitation-item-action-delete', 'destroy button not shown if the row is closed');
  assert.elementNotFound('.invitation-item-action-rescind', 'rescind not shown when the invitation is pending');
  assert.elementFound('.invitation-item-action-send', 'send button shown when the invitation is pending');
});

test('the row is in the closed state, in the previous round', function(assert) {
  this.setProperties({
    'invitation.state': 'pending',
    currentRound: false,
    uiState: 'closed'
  });
  this.render(openTemplate);
  assert.elementNotFound('.invitation-item-action-delete');
  assert.elementNotFound('.invitation-item-action-rescind');
  assert.elementNotFound('.invitation-item-action-send', 'cant send invites from previous rounds');

});

test('the row is in the show state, invitation is pending, and in current round', function(assert) {
  this.setProperties({
    'invitation.state': 'pending',
    currentRound: true,
    uiState: 'show'
  });

  this.render(openTemplate);

  assert.elementFound('.invitation-item-action-delete');
  assert.elementNotFound('.invitation-item-action-rescind', 'rescind not shown when the invitation is pending');
  assert.elementFound('.invitation-item-action-send', 'send button shown when the invitation is pending');
});

test('the row is in the show state, invitation is invited, and in current round', function(assert) {
  this.setProperties({
    'invitation.state': 'invited',
    currentRound: true,
    uiState: 'show'
  });

  this.render(openTemplate);

  assert.elementNotFound('.invitation-item-action-delete');
  assert.elementFound('.invitation-item-action-rescind');
  assert.elementNotFound('.invitation-item-action-send');
});

test('the row is in the show state, invitation is invited, and in previous round', function(assert) {
  this.setProperties({
    'invitation.state': 'invited',
    currentRound: false,
    uiState: 'show'
  });

  this.render(openTemplate);

  assert.elementNotFound('.invitation-item-action-delete');
  assert.elementNotFound('.invitation-item-action-rescind');
  assert.elementNotFound('.invitation-item-action-send');
});

test('the row is in the show state, invitation is declined, and in current round', function(assert) {
  this.setProperties({
    'invitation.state': 'declined',
    currentRound: true,
    uiState: 'show'
  });

  this.render(openTemplate);

  assert.elementNotFound('.invitation-item-action-delete');
  assert.elementNotFound('.invitation-item-action-rescind');
  assert.elementNotFound('.invitation-item-action-send');
});

test('grouped invitations are disabled when their primary has been invited or accepted', function(assert) {
  this.set('invitation', make('invitation', {
    email: 'jane@example.com',
    invitee: { fullName: 'Jane McEdits' },
    state: 'pending',
    title: 'Awesome Paper!',
    primary: make('invitation', {state: 'invited'})
  }));
  this.setProperties({
    currentRound: true,
    uiState: 'show'
  });

  this.render(openTemplate);
  assert.elementFound('.invitation-item--disabled');
  this.set('invitation.primary.state', 'accepted');
  assert.elementFound('.invitation-item--disabled');

  this.set('invitation.primary.state', 'pending');
  assert.elementNotFound('.invitation-item--disabled');
  this.set('invitation.primary.state', 'declined');
  assert.elementNotFound('.invitation-item--disabled');
});

function testAlternateState(state, shouldBeDisabled) {
  test(`grouped invitations are ${shouldBeDisabled ? 'disabled' : 'enabled'} when any alternate in the group is ${state}`, function(assert) {
    let alternate = make('invitation', {state: state});

    this.set('invitation', make('invitation', {
      email: 'jane@example.com',
      invitee: { fullName: 'Jane McEdits' },
      state: 'pending',
      title: 'Awesome Paper!',
      primary: make('invitation', {state: 'pending', alternates: [alternate]})
    }));
    this.setProperties({
      currentRound: true,
      uiState: 'show'
    });

    this.render(openTemplate);

    if (shouldBeDisabled) {
      assert.elementFound('.invitation-item--disabled');
    } else {
      assert.elementNotFound('.invitation-item--disabled');
    }
  });
}

testAlternateState('invited', true);
testAlternateState('accepted', true);
testAlternateState('pending', false);
testAlternateState('declined', false);

test('displays decline feedback when declined', function(assert){
  this.setProperties({
    'invitation.state': 'declined',
    'invitation.declineReason': 'No current availability',
    'invitation.reviewerSuggestions': 'Jane McReviewer'
  });

  const openTemplate = hbs`{{invitation-detail-row invitation=invitation
                                                   uiState='show'}}`;

  this.render(openTemplate);

  assert.textPresent('.invitation-item-decline-info', 'No current availability');
  assert.textPresent('.invitation-item-decline-info', 'Jane McReviewer');
});
