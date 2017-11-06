import {moduleFor, moduleForComponent, test} from 'ember-qunit';
import {make, manualSetup, mockCreate} from 'ember-data-factory-guy';
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

    let task = make('custom-card-task');
    this.set('task', task);
    mockCreate('answer');
  },

  afterEach() {
    $.mockjax.clear();
  }
});

test('it creates an answer for card-content', function(assert) {
  // add a single piece of answerable card content to work with
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  assert.expect(2);

  wait().then(() => {
    assert.elementsFound('input.card-input', 1);
    this.$('input.card-input').val('a new answer').trigger('input').blur();
  });

  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST');
  });
});

test('it does not create an answer for non answerables', function(assert) {

  // add a single piece of non-answerable card content to work with
  let cardContent = make('card-content', 'description');
  this.set('task.cardVersion.contentRoot', cardContent);

  assert.expect(1);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  return wait().then(() => {
    assert.equal(this.get('task.cardVersion.contentRoot.answers.length'), 0, 'there are no answers for a paragraph tag');
  });
});

test('it renders text for card-content', function(assert) {
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  assert.textPresent('.card-form-text', 'A short input question');
});

test('it renders a label for card-content', function(assert) {
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  return wait().then(() => {
    assert.elementFound('label.card-form-element');
  });
});

test('it displays an indicator for required fields', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: true, label: 'Label', text: 'Text', repetition: null });
  let root = 'task.cardVersion.contentRoot';
  this.set(root, cardContent);

  let text = `${root}.text`;
  let label = `${root}.label`;

  let template = hbs`
    {{custom-card-task task=task preview=false}}
  `;

  assert.expect(4);

  this.render(template);
  return wait().then(() => {
    assert.elementFound('.required-field', 'shows the required field indicator when both label and text are present');

    this.set(text, null);
    assert.elementFound('.required-field', 'shows the required field indicator in the label if no text');

    this.set(text, 'here');
    this.set(label, null);
    assert.elementFound('.required-field', 'shows the required field indicator in the text if no label');

    this.set(text, null);
    this.set(label, null);
    assert.elementFound('.required-field', 'shows the required field indicator when neither label nor text are present');
  });
});

test('it does not display an indicator for non-required fields', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: false });
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

  return wait().then(() => {
    assert.elementNotFound('.required-field');
  });
});

test('When having "false" as the content.defaultAnswerValue it casts it to boolean', function(assert) {
  let cardContent = make('card-content', 'checkBox');
  this.set('content', cardContent);
  this.set('owner', Ember.Object.create());
  this.set('preview', true);

  this.render(hbs` {{card-content content=content owner=owner preview=preview }}`);
  return wait().then(() => {
    assert.equal(this.$('input[type=checkbox]').is(':checked'), false);
  });
});

test('When having "true" as the content.defaultAnswerValue it casts it to boolean', function(assert) {
  let cardContent = make('card-content', 'checkBox');
  Ember.run(() => {
    cardContent.set('defaultAnswerValue', 'true');
  });
  this.set('content', cardContent);
  this.set('owner', Ember.Object.create());
  this.set('preview', true);

  this.render(hbs `{{card-content content=content owner=owner preview=preview }}`);
  return wait().then(() => {
    assert.equal(this.$('input[type=checkbox]').is(':checked'), true);
  });
});


moduleFor('component:card-content', 'Unit: Card Content Component', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
  }
});

test('it lazily saves new answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: false, defaultAnswerValue: null });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false});

  assert.notOk(component.shouldEagerlySave(answer));
});

test('it eagerly saves new required answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: true });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false});

  assert.ok(component.shouldEagerlySave(answer));
});

test('it eagerly saves new answers with default values', function(assert) {
  let cardContent = make('card-content', 'shortInput', { defaultAnswerValue: 'hippopotamus' });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);

  let answer = cardContent.answerForOwner(task);
  assert.equal(answer.get('value'), 'hippopotamus');

  let component = this.subject({content: cardContent, owner: task, preview: false});
  assert.ok(component.shouldEagerlySave(answer));
});
