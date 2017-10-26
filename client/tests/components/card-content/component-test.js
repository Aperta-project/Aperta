import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup, mockCreate } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('custom-card-task', 'Integration | Components | Card Content', {
  integration: true,

  beforeEach() {
    this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    let task = FactoryGuy.make('custom-card-task');
    this.set('task', task);
  }
});

test('it creates an answer for card-content', function(assert) {
  // add a single piece of answerable card content to work with
  let cardContent = FactoryGuy.make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);
  mockCreate('answer');

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  assert.elementsFound('input.form-control', 1);
  this.$('input.form-control').val('a new answer').trigger('input').blur();

  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST');
    $.mockjax.clear();
  });
});

test('it does not create an answer for non answerables', function(assert) {
  // add a single piece of non-answerable card content to work with
  let cardContent = FactoryGuy.make('card-content', 'description');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);
  assert.equal(this.get('task.cardVersion.contentRoot.answers.length'), 0, 'there are no answers for a paragraph tag');
});

test('it renders text for card-content', function(assert) {
  // add a single piece of non-answerable card content to work with
  let cardContent = FactoryGuy.make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);
  assert.textPresent('.content-text', 'A short input question');
});

test('it renders a label for card-content', function(assert) {
  // add a single piece of non-answerable card content to work with
  let cardContent = FactoryGuy.make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);
  assert.elementFound('.content-label');
});

test(`it displays an indicator if 'isRequired set to true`, function(assert) {
  let cardContent = FactoryGuy.make('card-content', 'shortInput', { requiredField: true, label: 'Label1', text: 'Text' });
  let root = 'task.cardVersion.contentRoot';
  this.set(root, cardContent);

  let text = `${root}.text`;
  let label = `${root}.label`;
  let template = hbs`
    {{custom-card-task task=task preview=false}}
  `;

  this.render(template);
  assert.elementFound('.content-label .required-field', 'shows the required field indicator when both label and text are present');

  this.set(text, null);
  this.render(template);
  assert.elementFound('.content-label .required-field', 'shows the required field indicator in the label if no text');

  this.set(text, 'here');
  this.set(label, null);
  this.render(template);
  assert.elementFound('.content-text .required-field', 'shows the required field indicator in the text if no label');

  this.set(text, null);
  this.set(label, null);
  this.render(template);
  assert.elementFound('.content-label .required-field', 'shows the required field indicator when neither label nor text are present');
});

test(`it does not display an field indicator if 'isRequired set to false`, function(assert) {
  let cardContent = FactoryGuy.make('card-content', 'shortInput', { requiredField: false });
  this.set('task.cardVersion.contentRoot', cardContent);

  this.set(
    'content',
    Ember.Object.create({
      ident: 'test',
      text: 'Test check-box',
      label: 'some label'
    })
  );

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  assert.elementNotFound('.required-field');
});


