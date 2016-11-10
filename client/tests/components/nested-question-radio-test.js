import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('nested-question-radio', 'Integration | Component | nested question radio', {
  integration: true
});

test('it renders', function(assert) {
  const fakeQuestion = Ember.Object.create({
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
    {{nested-question-radio ident="foo" owner=task}}
  `);

  assert.textPresent(this.$('.question-text'), 'Test Question');
  assert.elementFound('.foo-yes', '"Yes" radio found with class');
  assert.elementFound('.foo-no',  '"No"  radio found with class');
});
