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
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('link-alternate', 'Unit | Component | link alternate', {
  unit: true
});

test('#filteredAlternates does not include invitation', function(assert) {
  const invitationA = Ember.Object.create({id: 1});
  const invitationB = Ember.Object.create({id: 2, primary: invitationA});
  const invitationC = Ember.Object.create({id: 3, primary: invitationA});
  const invitationD = Ember.Object.create({id: 4});

  const component = this.subject({
    invitation: invitationA,
    invitations: [invitationA, invitationB, invitationC, invitationD]
  });

  const filteredAlternates = component.get('filteredAlternates');

  assert.notOk(
    filteredAlternates.contains(invitationA),
    'it should not include the invitation itself'
  );

  assert.ok(
    filteredAlternates.contains(invitationD),
    'it should include other invitations'
  );
});

test('#filteredAlternates does not include invitations already linked', function(assert) {
  const invitationA = Ember.Object.create({id: 1});
  const invitationB = Ember.Object.create({id: 2, state: 'accepted'});
  const invitationC = Ember.Object.create({id: 3, primary: invitationB});
  const invitationD = Ember.Object.create({id: 4});

  const component = this.subject({
    invitation: invitationA,
    invitations: [invitationA, invitationB, invitationC, invitationD]
  });

  const filteredAlternates = component.get('filteredAlternates');

  assert.ok(
    filteredAlternates.contains(invitationB),
    'it should include accepted primary'
  );

  assert.notOk(
    filteredAlternates.contains(invitationC),
    'it should not include invitation already linked'
  );

  assert.ok(
    filteredAlternates.contains(invitationD),
    'it should include non linked invitations'
  );
});
