import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/tech-check',
  'Integration | Component | card content | tech check',
  {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      registerCustomAssertions();
      this.set('actionStub', function() {});
      this.set('content', Ember.Object.create({ ident: 'test' }));
      this.set('answer', Ember.Object.create({ value: null }));
    }
  }
);

let template = hbs`{{card-content/tech-check
content=content
disabled=disabled
owner=owner
answer=answer
preview=true
valueChanged=(action actionStub)
}}`;

let createCheckWithSendback = () => {
  let tc = make('card-content', {
    contentType: 'tech-check',
    valueType: 'boolean'
  });
  let sendback = make('card-content', {
    contentType: 'sendback-reason',
    parent: tc
  });
  let checkbox = make('card-content', {
    contentType: 'check-box',
    valueType: 'boolean',
    parent: sendback
  });
  make('card-content', {
    // pencil
    contentType: 'check-box',
    valueType: 'boolean',
    parent: sendback
  });
  make('card-content', {
    // sendback reason textarea
    contentType: 'paragraph-input',
    parent: sendback
  });
  return [tc, checkbox];
};
test(`it displays the 'Pass' label`, function(assert) {
  this.set('labelText', 'my label');
  this.render(template);
  assert.textPresent('.checked-label-text', 'Pass');
});

test(`it displays content.text as unescaped html`, function(assert) {
  this.set('content', Ember.Object.create({ text: '<b class="foo">Foo</b>' }));
  this.render(template);
  assert.elementFound('.content-text b.foo');
});

test(`the label is for the input`, function(assert) {
  this.set('content', Ember.Object.create({ label: 'test' }));
  this.render(template);
  assert.ok(
    this.$('input').attr('name'),
    'the name is set automatically if no ident'
  );
  assert.ok(
    this.$('input').attr('id'),
    'the id is set automatically if no ident'
  );
  assert.ok(
    this.$('label').attr('for'),
    'the for is set automatically if no ident'
  );
  assert.equal(this.$('label').attr('for'), this.$('input').attr('name'));
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  //create sendback data
  let owner = make('custom-card-task');
  let tc = createCheckWithSendback()[0];

  this.set('owner', owner);
  this.set('content', tc);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('.card-content-toggle-switch input').click();
});

test(`toggling to 'Pass' will clear any existing sendbacks`, function(assert) {
  let owner = make('custom-card-task');
  let [tc, sendbackCheck] = createCheckWithSendback();
  // check the box for the sendback
  make('answer', { owner: owner, value: true, cardContent: sendbackCheck });
  this.set('owner', owner);
  this.set('content', tc);
  this.render(template);

  assert.elementFound(
    `.sendback-reason-row input[type="checkbox"]:checked`,
    'the checkbox starts checked'
  );

  this.$('.card-content-toggle-switch input').click();
  assert.elementNotFound(
    `.sendback-reason-row input[type="checkbox"]:checked`,
    'the checkbox becomes unchecked'
  );
});

test(`checking a sendback will set the toggle to 'Fail' and send 'valueChanged'`, function() {});
