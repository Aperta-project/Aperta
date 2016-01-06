import Ember from 'ember';
import { test, moduleFor } from 'ember-qunit';

moduleFor(
  'controller:admin/journal/flow-manager',
  'Unit: controller/journalFlowManager'
);

test('newFlowPosition puts the new flow at the highest position', function(assert) {
  const flows = [
    Ember.Object.create({
      position: 1
    }), Ember.Object.create({
      position: 2
    })
  ];

  const oldRole = Ember.Object.create({
    flows: flows
  });

  const controller = this.subject();

  controller.set('model', oldRole);
  assert.equal(controller.newFlowPosition(), 3);
});
