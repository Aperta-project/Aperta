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
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}, {}],
    question: 'Test Question',
    answer: true,
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    questions: [fakeQuestion]
  }));

  this.render(hbs`
    {{#question-check ident="foo" task=task}}
      {{#additional-datasets}}{{/additional-datasets}}
    {{/question-check}}
  `);

  assert.equal(this.$(".question-dataset").length, 2, 'Renders a dataset for each one in the model');
  assert.ok(this.$("button:contains('Add Dataset')").length, 'Renders an Add Dataset button');
});

test('with additional-datasets it renders them and a button to add more', function(assert) {
   let additionalDataItem = {
     contact: "test contact",
     description: "test description",
     accession: "test doi",
     reasons: "test reasons",
     title: "test title",
     url: "test url"
   };

  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [additionalDataItem],
    question: 'Test Question',
    answer: true,
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    questions: [fakeQuestion]
  }));

  this.render(hbs`
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
  `);

  let assertValue = function(context, selector, value, message) {
    return assert.equal(context.$(selector).val(), value, message);
  };

  assertValue(this, 'textarea[name="contact"]',  'test contact',     'contact is a textarea');
  assertValue(this, 'input[name="description"]', 'test description', 'description is an input');
  assertValue(this, 'input[name="accession"]',   'test doi',         'doi is an input');
  assertValue(this, 'input[name="title"]',       'test title',       'title is an input');
  assertValue(this, 'input[name="url"]',         'test url',         'url is an input');
  assertValue(this, 'textarea[name="reasons"]',  'test reasons',     'reasons is a textarea');

  this.$('input[name="description"]').val('New description').change();
  this.$('textarea[name="contact"]').val('New contact').change();
  assert.equal(additionalDataItem.description, 'New description', 'additionalData syncs inputs to the value of the fields');
  assert.equal(additionalDataItem.contact,     'New contact',     'additionalData syncs to the textareas to the value of the fields');
});

// test('it uses dataset-* components to render attributes on additonalData', function() {
//   var $component, additionalDataItem, assertValue, component, fakeQuestion, task, template;
//   additionalDataItem = {
//     contact: "test contact",
//     description: "test description",
//     accession: "test doi",
//     reasons: "test reasons",
//     title: "test title",
//     url: "test url"
//   };
//   fakeQuestion = Ember.Object.create({
//     ident: "foo",
//     save: function() {
//       return null;
//     },
//     additionalData: [additionalDataItem],
//     question: "Test Question",
//     answer: true
//   });
//   task = Ember.Object.create({
//     questions: [fakeQuestion]
//   });
//   template = "{{#additional-datasets}} {{dataset-contact}} {{dataset-description}} {{dataset-doi}} {{dataset-reasons}} {{dataset-title}} {{dataset-url}} {{/additional-datasets}}";
//   component = this.subject({
//     ident: "foo",
//     task: task,
//     template: Ember.Handlebars.compile(template)
//   });
//   this.render();
//   $component = this.subject().$();
//   assertValue = function(component, selector, value, message) {
//     return equal(component.find(selector).val(), value, message);
//   };
//   assertValue($component, "textarea[name='contact']", 'test contact', 'contact is a textarea');
//   assertValue($component, "input[name='description']", 'test description', 'description is an input');
//   assertValue($component, "input[name='accession']", 'test doi', 'doi is an input');
//   equal($component.find("textarea[name='reasons']").val(), 'test reasons', 'reasons is a textarea');
//   assertValue($component, "input[name='title']", 'test title', 'title is an input');
//   assertValue($component, "input[name='url']", 'test url', 'url is an input');
//   fillIn("input[name='description']", "New description");
//   fillIn("textarea[name='contact']", "New contact");
//   return andThen(function() {
//     equal(additionalDataItem.description, 'New description', 'additionalData syncs inputs to the value of the fields');
//     return equal(additionalDataItem.contact, 'New contact', 'additionalData syncs to the textareas to the value of the fields');
//   });
// });
