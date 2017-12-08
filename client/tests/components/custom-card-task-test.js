import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('custom-card-task', 'Integration | Components | Tasks | Custom Card Task', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);
  }
});

test('it renders the custom card content starting in a non error state', function(assert) {
  // factory builds a CustomCardTask along with a piece of sample CardContent
  let task = FactoryGuy.make('custom-card-task', {notReady: false});
  this.set('task', task);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.render(hbs`
    {{custom-card-task task=task}}
  `);

  assert.elementFound('.card-content-short-input', 'found the associated card content');
  assert.elementFound('.task-completed.button--green', 'non error state button is green');
  assert.elementNotFound('.task-completed-section .error-message', 'non error state contains no error message');
});


test('if errors are present on submit, the complete button gets an error state', function(assert) {
  // factory builds a CustomCardTask along with a piece of sample CardContent
  let task = FactoryGuy.make('custom-card-task', {notReady: true});
  this.set('task', task);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.render(hbs`
    {{custom-card-task task=task}}
  `);

  assert.elementFound('.task-completed.button--green', 'error state button is green');
  assert.elementFound('.task-completed-section .error-message', 'error state contains error message');
});
