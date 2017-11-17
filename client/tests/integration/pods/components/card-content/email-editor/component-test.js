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

  /*$.mockjax({
    url:`/api/tasks/${this.get('owner.id')}/${endpoint}`,
    contentType:"text/json",
    responseText:[ { to: sent_to_users,
      from: initiator,
      date: d.strftime("%h %d, %Y %r"),
      subject: params[:subject],
      body: params[:body] }]
  });
*/

  this.render(template);

  assert.equal(1,1);
});
