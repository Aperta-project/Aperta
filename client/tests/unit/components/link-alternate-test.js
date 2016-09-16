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

  assert.notOk(
    filteredAlternates.contains(invitationA),
    'it should not include invitation'
  );

  assert.ok(
    filteredAlternates.contains(invitationB),
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

  assert.notOk(
    filteredAlternates.contains(invitationC),
    'it should not include invitation already linked'
  );

  assert.ok(
    filteredAlternates.contains(invitationD),
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

  assert.notOk(
    filteredAlternates.contains(invitationB),
    'it should not include accepted primary'
  );

  assert.notOk(
    filteredAlternates.contains(invitationC),
    'it should not include alternate of accepted primary'
  );

  assert.ok(
    filteredAlternates.contains(invitationD),
    'it should include other invitations'
  );
});
