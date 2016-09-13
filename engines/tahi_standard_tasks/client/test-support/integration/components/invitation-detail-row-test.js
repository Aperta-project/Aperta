import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('invitation-detail-row', 'Integration | Component | invitation detail row', {
  integration: true,
  beforeEach() {
    this.set('update-date', new Date('January 01, 2016'));
    this.set('invitation', Ember.Object.create({
      declineReason: null,
      declined: false,
      email: 'jane@example.com',
      invitee: Ember.Object.create({
        fullName: 'Jane McEdits'
      }),
      reviewerSuggestions: null,
      state: 'pending',
      title: 'Awesome Paper!',
      updatedAt: this.get('update-date')
    }));
  }
});

let template = hbs`{{invitation-detail-row
                      invitation=invitation}}`;

test('displays invitation information if the invite.invited is true', function(assert){
  this.set('invitation.state', 'invited');
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

test('displays delete icon if invite is pending, the row is in the show state, and in current round', function(assert) {
  this.setProperties({
    'invitation.pending': true,
    currentRound: true,
    uiState: 'show'
  });

  const openTemplate = hbs`{{invitation-detail-row allowDestroy=allowDestroy
                                                   invitation=invitation
                                                   currentRound=currentRound
                                                   uiState=uiState}}`;

  this.render(openTemplate);

  assert.elementFound('.invitation-item-action-delete', 'destroy button is found');

  this.setProperties({
    'invitation.pending': true,
    currentRound: false,
    uiState: 'show'
  });

  assert.elementNotFound('.invitation-item-action-delete', 'destroy button not shown if not current round');

  this.setProperties({
    'invitation.pending': false,
    currentRound: true,
    uiState: 'show'
  });

  assert.elementNotFound('.invitation-item-action-delete', 'destroy button not shown if invitation is not pending');

  this.setProperties({
    'invitation.pending': true,
    currentRound: true,
    uiState: 'closed'
  });

  assert.elementNotFound('.invitation-item-action-delete', 'destroy button not shown if the row is closed');
});

test('displays decline feedback when declined', function(assert){
  this.setProperties({
    'invitation.declined': true,
    'invitation.declineReason': 'No current availability',
    'invitation.reviewerSuggestions': 'Jane McReviewer'
  });

  const openTemplate = hbs`{{invitation-detail-row invitation=invitation
                                                   uiState='show'}}`;

  this.render(openTemplate);

  assert.textPresent('.invitation-item-decline-info', 'No current availability');
  assert.textPresent('.invitation-item-decline-info', 'Jane McReviewer');
});
