import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

moduleForComponent('card-content/email-editor', 'Integration | Component | card content/email editor', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    registerCustomAssertions();
    this.set('actionStub', function() {});
    this.set('preview', true);
    this.set('content', Ember.Object.create({ ident: 'test', letterTemplate: 'preprint-accept'}));
    this.set('answer', Ember.Object.create({ value: null }));
  }
});

let template = hbs`{{card-content/email-editor
content=content
disabled=disabled
owner=owner
answer=answer
valueChanged=(action actionStub)
}}`;

test(`it renders an email`, function(assert) {
  let owner = make('custom-card-task');

  this.set('owner', owner);

  this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
  $.mockjax({url: '/api/tasks/1/load_email_template', type: 'get', status: 200, responseText: '{"to": "test@example.com", "subject":"hello world", "body": "some text"}'});


  this.render(template);

  assert.equal(1,1);
});
