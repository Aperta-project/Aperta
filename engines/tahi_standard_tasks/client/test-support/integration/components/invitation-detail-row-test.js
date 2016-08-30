import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('invitation-detail-row',
                    'Integration | Component | invitation detail row', {
                      integration: true,
                      beforeEach: function() {
                        this.set('update-date', new Date('January 01, 2016'));
                        this.set('destroyAction', () => {return;});
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
                      invitation=invitation
                      destroyAction=destroyAction}}`;

test('displays invitation information if the invite.invited is true', function(assert){
  this.set('invitation.invited', true);
  this.render(template);

  assert.textPresent('.invitation-item-status',
                     `Invited ${moment(this.get('update-date')).format('MMM D, YYYY')}`);
});

test('displays invitee information when present', function(assert){
  this.render(template);

  assert.textPresent('.invitation-item-full-name', 'Jane McEdits');
  assert.textNotPresent('.invitation-item-full-name', 'jane@example.com');
});

test('displays invitation email when no invitee present', function(assert){
  this.set('invitation.invitee', null);
  this.render(template);

  assert.textNotPresent('.invitation-item-full-name', 'Jane McEdits');
  assert.textPresent('.invitation-item-full-name', 'jane@example.com');
});

test('displays remove icon if invite not accepted and the row is in the show or edit state',
  function(assert){
    this.set('invitation.accepted', false);
    let openTemplate = hbs`{{invitation-detail-row
                          invitation=invitation
                          uiState='show'
                          destroyAction=destroyAction}}`;
    this.render(openTemplate);

    assert.elementFound('.invite-remove');
  }
);

test('does not display remove icon if invite accepted, even if in the show state',
  function(assert){
    this.set('invitation.accepted', true);
    let openTemplate = hbs`{{invitation-detail-row
                          invitation=invitation
                          uiState='show'
                          destroyAction=destroyAction}}`;
    this.render(openTemplate);

    assert.elementNotFound('.invite-remove');
  }
);

test('displays decline feedback when declined', function(assert){
  this.set('invitation.declined', true);
  this.set('invitation.declineReason', 'No current availability');
  this.set('invitation.reviewerSuggestions', 'Jane McReviewer');
  this.render(template);

  assert.textPresent('.invitation-decline-reason', 'No current availability');
  assert.textPresent('.invitation-reviewer-suggestions', 'Jane McReviewer');
});
