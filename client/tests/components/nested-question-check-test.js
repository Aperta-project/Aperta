import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('nested-question-check', 'NestedQuestionCheckComponent', {
  integration: true
});

test('it renders', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create(); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

  this.render(hbs`
    {{nested-question-check ident="foo" owner=task}}
  `);

  assert.equal(this.$('label:contains("Test Question")').length, 1);
});
