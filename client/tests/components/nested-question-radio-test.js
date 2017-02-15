import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';

moduleForComponent('nested-question-radio', 'Integration | Component | nested question radio', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
  }
});

test('it renders', function(assert) {
  make('card-content', { ident: 'foo' , text: 'Test Question' });
  make('ad-hoc-task');

  this.render(hbs`
    {{nested-question-radio ident="foo" owner=task}}
  `);

  assert.textPresent(this.$('.question-text'), 'Test Question');
  assert.elementFound('.foo-yes', '"Yes" radio found with class');
  assert.elementFound('.foo-no',  '"No"  radio found with class');
});
