import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('question-check', 'QuestionCheckComponent', {
  integration: true
});

test('it renders', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    question: 'Test Question',
    answer: true,
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    questions: [fakeQuestion]
  }));

  this.render(hbs`
    {{question-check ident="foo" task=task}}
  `);

  assert.equal(this.$('label:contains("Test Question")').length, 1);
});
