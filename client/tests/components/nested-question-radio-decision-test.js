import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('nested-question-radio', 'Integration | Component | nested question radio decision', {
  integration: true
});

test('shows help text in disabled state', function(assert) {
  const fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function () { return Ember.Object.create(); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function () { return fakeQuestion; }
  }));

  this.render(hbs`{{nested-question-radio-decision ident="foo" owner=task helpText="Something helpful" unwrappedHelpText="Something helpfuls" disabled=true}}`);
  assert.textPresent('.question-help', 'Something helpful');
  assert.textPresent('div', 'Something helpfuls');
});
