import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('additional-datasets', 'AdditionalDatasets', {
  integration: true
});

test('with additional-datasets it renders them and a button to add more', function(assert) {
  let question = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}, {}],
    question: 'Test Question',
    answer: true,
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    questions: [question]
  }));

  this.render(hbs(`
    {{#question-check ident="foo" task=task}}
      {{#additional-datasets}}{{/additional-datasets}}
    {{/question-check}}
  `));

  assert.equal(this.$(".question-dataset").length, 2, 'Renders a dataset for each one in the model');
  assert.ok(this.$("button:contains('Add Dataset')").length, 'Renders an Add Dataset button');
});

test('it uses dataset-* components to render attributes on additionalData', function(assert) {
   let additionalDataItem = {
     contact: "test contact",
     description: "test description",
     accession: "test doi",
     reasons: "test reasons",
     title: "test title",
     url: "test url"
   };

  let question = Ember.Object.create({
    ident: 'foo',
    additionalData: [additionalDataItem],
    question: 'Test Question',
    answer: true,
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    questions: [question]
  }));

  this.render(hbs(`
    {{#question-check ident="foo" task=task}}
      {{#additional-datasets}}
        {{dataset-contact}}
        {{dataset-description}}
        {{dataset-doi}}
        {{dataset-reasons}}
        {{dataset-title}}
        {{dataset-url}}
      {{/additional-datasets}}
    {{/question-check}}
  `));

  assert.equal(this.$('textarea[name="contact"]').val(),  'test contact',     'contact is a textarea');
  assert.equal(this.$('input[name="description"]').val(), 'test description', 'description is an input');
  assert.equal(this.$('input[name="accession"]').val(),   'test doi',         'doi is an input');
  assert.equal(this.$('input[name="title"]').val(),       'test title',       'title is an input');
  assert.equal(this.$('input[name="url"]').val(),         'test url',         'url is an input');
  assert.equal(this.$('textarea[name="reasons"]').val(),  'test reasons',     'reasons is a textarea');

  this.$('input[name="description"]').val('New description').change();
  this.$('textarea[name="contact"]').val('New contact').change();

  assert.equal(additionalDataItem.description, 'New description', 'additionalData syncs inputs to the value of the fields');
  assert.equal(additionalDataItem.contact,     'New contact',     'additionalData syncs to the textareas to the value of the fields');
});
