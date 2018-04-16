/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
                      loading=loading
                      }}`;

test('pending invitation loads with accept/decline options', function(assert){
  this.set('loading', false);
  this.render(template);

  assert.textPresent('.invitation-type', 'Reviewer Invitation');
  assert.textPresent('button.invitation-accept', 'Accept Reviewer Invitation');
  assert.textPresent('button.invitation-decline', 'Decline');
  assert.elementFound('.pending-invitation', 'flagged as pending invitation');
});

test('shows spinner when loading prop is true', function(assert){
  this.set('loading', true);
  this.render(template);

  assert.elementFound('.progress-spinner', 'has progress spinner');
});
