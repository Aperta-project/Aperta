import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('link-alternate', 'Unit | Component | link alternate', {
  unit: true
});

test('#filteredAlternates does not include invitation', function(assert) {
  const invitationA = Ember.Object.create({id: 1});
  const invitationB = Ember.Object.create({id: 2});
  const invitationC = Ember.Object.create({id: 3});

  const component = this.subject({
    invitation: invitationA,
    invitations: [invitationA, invitationB, invitationC]
  });

  const filteredAlternates = component.get('filteredAlternates');

  assert.equal(
    filteredAlternates.contains(invitationA), false,
    'it should not include invitation'
  );

  assert.equal(
    filteredAlternates.contains(invitationB), true,
    'it should include other invitations'
  );
});

test('#filteredAlternates does not include invitations already linked', function(assert) {
  const invitationA = Ember.Object.create({id: 1});
  const invitationB = Ember.Object.create({id: 2});
  const invitationC = Ember.Object.create({id: 3, primary: invitationB});
  const invitationD = Ember.Object.create({id: 4});

  const component = this.subject({
    invitation: invitationA,
    invitations: [invitationA, invitationB, invitationC, invitationD]
  });

  const filteredAlternates = component.get('filteredAlternates');

  assert.equal(
    filteredAlternates.contains(invitationC), false,
    'it should not include invitation already linked'
  );

  assert.equal(
    filteredAlternates.contains(invitationD), true,
    'it should include non linked invitations'
  );
});

test('#filteredAlternates does not include accepted', function(assert) {
  const invitationA = Ember.Object.create({id: 1});
  const invitationB = Ember.Object.create({id: 2, state: 'accepted'});
  const invitationC = Ember.Object.create({id: 3, primary: invitationB});
  const invitationD = Ember.Object.create({id: 4});

  const component = this.subject({
    invitation: invitationA,
    invitations: [invitationA, invitationB, invitationC, invitationD]
  });

  const filteredAlternates = component.get('filteredAlternates');

  assert.equal(
    filteredAlternates.contains(invitationB), false,
    'it should not include accepted primary'
  );

  assert.equal(
    filteredAlternates.contains(invitationC), false,
    'it should not include alternate of accepted primary'
  );

  assert.equal(
    filteredAlternates.contains(invitationD), true,
    'it should include other invitations'
  );
});
