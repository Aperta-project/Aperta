import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';
import testQAIdent from 'tahi/tests/helpers/test-mixins/qa-ident';

moduleForComponent('card-content/email-editor', 'Integration | Component | card content/email editor', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    registerCustomAssertions();
    let owner = make('custom-card-task');
    let answer = Ember.Object.create({ owner: owner, value: null, save: function(){}});
    this.set('owner', owner);
    this.set('answer', answer);
    this.set('disabled', false);
    this.set('actionStub', function() {});
    this.set('preview', true);
    this.set('repetition', null);
    this.set('content', Ember.Object.create({
      ident: 'test',
      letterTemplate: 'preprint-accept',
      answers: [answer]
    }));
  }
});

let template = hbs`{{card-content/email-editor
content=content
disabled=disabled
owner=owner
answer=answer
repetition=repetition
valueChanged=(action actionStub)
}}`;

test(`it renders an email-editor initialized by the template`, function(assert) {
  this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
  $.mockjax({url: '/api/tasks/1/load_email_template', type: 'get', status: 200, responseText: '{"letter_template": {"to": "test@example.com", "subject":"hello world", "body": "some text"}}'});

  this.render(template);

  return wait().then(() => {
    assert.elementFound(
      `.email-editor`, 'email editor is visible after generated'
    );
    assert.equal($('input.to-field').val().trim(), 'test@example.com', 'the email displays the recipient');
    assert.equal($('input.subject-field').val().trim(), 'hello world', 'the email displays the correct subject');
    assert.elementFound(
      `.email-editor .button-primary`, 'email editor has a send email button'
    );
  });
});

test(`it renders an email-editor initialized by a template and sends the template`, function(assert) {
  this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
  $.mockjax({url: '/api/tasks/1/load_email_template', type: 'get', status: 200, responseText: '{"letter_template": {"to": "test@example.com", "subject":"hello world", "body": "some text"}}'});
  $.mockjax({url: '/api/tasks/1/send_message_email', type: 'PUT', status: 201, responseText: '{"letter_template": {"to": ["test@example.com", "test2@example.com"], "from": "initiator@example.com", "date": "Nov 17, 2017 11:45pm", "subject":"hello world", "body": "some text"}}'});

  this.render(template);

  return wait().then(() => {
    this.$('.email-editor .button-primary').click();
    return wait().then(() => {
      assert.mockjaxRequestMade({url: '/api/tasks/1/send_message_email', type: 'PUT'}, 'it saves the sendback after clearing it');
      assert.elementFound(
        `.email-readonly-summary`, 'email editor is displaying read-only summary'
      );
      assert.equal($('td.read-only-subject').text().trim(), 'hello world', 'the email read-only summary displays the selection subject');
      assert.equal($('td.read-only-to').text().trim(), 'test@example.com,test2@example.com', 'the email read-only summary displays the list of recipients');
      assert.equal($('td.read-only-from').text().trim(), 'initiator@example.com', 'the email read-only summary displays the initiator');
      assert.equal($('td.read-only-date').text().trim(), 'Nov 17, 2017 11:45pm', 'the email read-only summary displays the date');
    });
  });
});

testQAIdent(template);
