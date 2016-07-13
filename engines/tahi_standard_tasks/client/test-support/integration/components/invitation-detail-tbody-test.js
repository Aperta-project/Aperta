import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('invitation-detail-tbody',
                    'Integration | Component | invitation detail tbody', {
                      integration: true,
                      beforeEach: function() {
                        this.set('update-date', new Date('January 01, 2016'));
                        this.set('destroyAction', () => {return;});
                        this.set('invitation', Ember.Object.create({
                          accepted: false,
                          declineReason: null,
                          declined: true,
                          reviewerSuggestions: null,
                          state: 'declined',
                          title: 'Awesome Paper!'
                        }));
                        this.set('invitations',[this.get('invitation')]);
                      }
                    });

let template = hbs`{{invitation-detail-tbody invitations=invitations}}`;

test('displays decline feedback when declined', function(assert){
  this.set('invitation.declineReason', 'No current availability');
  this.set('invitation.reviewerSuggestions', 'Jane McReviewer');
  this.render(template);

  assert.textPresent('.invitation-decline-reason', 'No current availability');
  assert.textPresent('.invitation-reviewer-suggestions', 'Jane McReviewer');
});
