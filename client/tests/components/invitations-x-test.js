import Ember from 'ember';
import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('invitations-x',
                   'Integration | Component | invitations-x',
                   {integration: true,
                    beforeEach: function() {
                      this.set('accept', () => {return;});
                      this.set('close', () => {return;});
                      this.set('decline', () => {return;});
                      this.set('update', () => {return;});

                      this.set('invitation', Ember.Object.create({
                        declineReason: null,
                        inviteeRole: 'Reviewer',
                        pendingFeedback: false,
                        reviewerSuggestions: null,
                        state: 'pending',
                        title: 'Awesome Paper!'
                      }));
                      this.set('invitations',[this.get('invitation')]);
                    }});

var template = hbs`{{invitations-x invitations=invitations
                      accept=(action accept invitation)
                      close=(action close invitation)
                      decline=(action decline invitation)
                      update=(action update invitation)
                      }}`;

test('pending invitation loads with accept/decline options', function(assert){
  this.render(template);

  assert.textPresent('h2', 'Reviewer Invitation');
  assert.textPresent('button.invitation-accept', 'Accept Reviewer Invitation');
  assert.textPresent('button.invitation-decline', 'Decline');
  assert.elementFound('.pending-invitation', 'flagged as pending invitation');
  assert.elementFound('.dashboard-paper-title', 'has paper title');
});
