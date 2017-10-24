import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';
import { manualSetup, make } from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

moduleForComponent('invitation-detail-row', 'Integration | Component | invitation detail row', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    var can = FakeCanService.create();
    var task = make('task');
    this.registry.register('service:can', can.allowPermission('manage_invitations', task).asService());
    this.set('owner', task);
    this.set('update-date', new Date('January 01, 2016'));
    this.set('completed-date', new Date('March 01, 2016'));
    this.set('due-at'), new Date('February 25, 2017)');
    this.set('reviewerReport', make('reviewer-report'));
    this.set('invitation', make('invitation', {
      declineReason: null,
      declined: false,
      email: 'jane@example.com',
      invitee: { fullName: 'Jane McEdits', id: 1},
      actor: { fullName: 'Some Editor', id: 2},
      reviewerSuggestions: null,
      reviewerReport: this.get('reviewerReport'),
      state: 'pending',
      title: 'Awesome Paper!',
      updatedAt: this.get('update-date')
    }));
  }
});

let template = hbs`{{invitation-detail-row
                      invitation=invitation
                      owner=owner
                      uiState='closed'}}`;

test('displays invitation information if invitation.invited is true', function(assert){
  this.set('invitation.state', 'invited');
  this.set('invitation.invitedAt', this.get('update-date'));
  this.render(template);

  assert.textPresent('.invitation-item-status',
                     `Invited ${moment(this.get('update-date')).format('MMM D, YYYY')}`);
});

test('displays review report status if invitation.accepted is true', function(assert){
  this.set('invitation.state', 'accepted');
  this.set('invitation.reviewerReport.status', 'pending');
  this.render(template);

  assert.textPresent('.invitation-item-status', 'Review due');
});

test('displays reviewer report due date if invitation.accepted is true', function(assert){
  this.set('invitation.state', 'accepted');
  this.set('invitation.reviewerReport.status', 'pending');
  this.render(template);

  assert.textPresent('.invitation-item-status', 'Jul 4');
});

test('displays invitation information if invitation.accepted is true and report complete', function(assert){
  this.set('invitation.reviewerReport.status', 'completed');
  this.set('invitation.reviewerReport.statusDatetime', this.get('completed-date'));
  this.set('invitation.state', 'accepted');
  this.render(template);

  assert.textPresent('.invitation-item-status',
                     `Completed ${moment(this.get('completed-date')).format('MMM D, YYYY')}`);
});

test('does not show a pending review status for an accepted invitation unless it is a reviewer invitation', function(assert){
  this.set('invitation.reviewerReport', null);
  this.set('invitation.state', 'accepted');
  this.render(template);

  assert.textNotPresent('.invitation-item-status', 'Pending');
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
                                               owner=owner
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

test('the row is in the closed state, invitation is invited, in the current round', function(assert) {
  this.setProperties({
    'invitation.state': 'invited',
    currentRound: true,
    uiState: 'closed'
  });
  this.render(openTemplate);
  assert.elementNotFound('.invitation-item-action-delete', 'destroy button not shown if the row is closed');
  assert.elementNotFound('.invitation-item-action-rescind', 'rescind not shown when the invitation is invited');
  assert.elementNotFound('.invitation-item-action-send', 'send button not shown when the invitation is invited');
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

test('the row is in the show state, invitation is invited, and in current round', function(assert) {
  assert.expect(2);
  const spy = sinon.spy();
  this.setProperties({
    'invitation.state': 'invited',
    currentRound: true,
    uiState: 'show',
    'invitation.accept': spy
  });

  this.render(openTemplate);

  assert.textPresent('.invitation-item-action', 'Accept invitation for reviewer', 'Shows Accept button');
  this.$('.invitation-item-action-accept').click();

  assert.spyCalled(spy, 'clicking on button invokes invitation.accept()');
});

test('the row is in the show state, invitation is invited, and in current round but invitee has no id', function(assert) {
  this.setProperties({
    'invitation.state': 'invited',
    currentRound: true,
    uiState: 'show',
    'invitation.invitee': {}
  });

  this.render(openTemplate);

  assert.elementNotFound('.invitation-item-action-accept', 'Does not show Accept button');
});

test('the row is in the show state, invitation is accepted, and in current round', function(assert) {
  this.setProperties({
    'invitation.state': 'accepted',
    currentRound: true,
    uiState: 'closed'
  });

  this.render(openTemplate);

  assert.textPresent('.invitation-item-status', this.get('invitation.actor.fullName'), 'Shows actor name');
});

test('the row is in the show state, invitation is accepted, there is no actor, and in current round', function(assert) {
  this.setProperties({
    'invitation.state': 'accepted',
    currentRound: true,
    uiState: 'closed',
    'invitation.actor': null
  });

  this.render(openTemplate);

  assert.textNotPresent('.invitation-item-status', 'Accepted by', 'Does not show actor name');
});

test('the row is in the show state, invitation is invited, and in current round, but no permission', function(assert) {
  this.setProperties({
    'invitation.state': 'invited',
    currentRound: true,
    uiState: 'show'
  });

  this.registry.register('service:can', FakeCanService.create().asService());

  this.render(openTemplate);

  assert.elementNotFound('.invitation-item-action-accept', 'Does not show Accept button');
  assert.elementNotFound('.invitation-item-action-rescind', 'Does not show Rescind button');
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
                                                   owner=owner
                                                   uiState='show'}}`;

  this.render(openTemplate);

  assert.textPresent('.invitation-item-decline-info', 'No current availability');
  assert.textPresent('.invitation-item-decline-info', 'Jane McReviewer');
});

test('that dragging text does not trigger invite dragging when dragging is disabled', function(assert) {
  const spy = sinon.spy();
  this.set('startedDragging', spy);
  this.set('invitationIsExpanded', true); // will disable dragging
  const openTemplate = hbs`{{invitation-detail-row invitation=invitation
                                                   owner=owner
                                                   uiState='show'
                                                   invitationIsExpanded=invitationIsExpanded
                                                   startedDragging=(action startedDragging)}}`;

  this.render(openTemplate);
  const invitationBody = this.$('.invitation-show-body');
  invitationBody.trigger('dragstart', ['custom', 'shit']);
  assert.spyNotCalled(spy, 'dragging should not have started');
});
