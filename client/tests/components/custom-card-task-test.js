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

    // factory builds a CustomCardTask along with a piece of sample CardContent
    let task = FactoryGuy.make('custom-card-task');
    this.set('task', task);
  }
});

test('it renders the custom card content', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{custom-card-task task=task}}
  `);

  assert.elementFound('.card-content-short-input', 'found the associated card content');
});
