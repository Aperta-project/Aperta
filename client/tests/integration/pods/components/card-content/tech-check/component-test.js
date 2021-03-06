/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
      let paper  = make('paper', {'publishingState': 'submitted'});
      let task =  make('custom-card-task', {'paper': paper});
      this.set('owner', task);
      this.set('actionStub', function() {});
      this.set('preview', true);
      this.set('repetition', null);
      this.set('content', Ember.Object.create({ ident: 'test' }));
      this.set('answer', Ember.Object.create({ value: null }));
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

let template = hbs`{{card-content/tech-check
content=content
disabled=disabled
owner=owner
answer=answer
preview=preview
repetition=repetition
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

let createCheckWithEmail = () => {
  let tc = make('card-content', {
    contentType: 'tech-check',
    valueType: 'boolean'
  });
  let sendback = make('card-content', {
    contentType: 'sendback-reason',
    parent: tc
  });
  make('card-content', {
    contentType: 'check-box',
    valueType: 'boolean',
    parent: sendback
  });
  let tce = make('card-content', {
    contentType: 'tech-check-email',
    parent: tc
  });
  let intro = make('card-content', {
    contentType: 'paragraph-input',
    ident: 'tech-check-email--email-intro',
    defaultAnswerValue: 'the intro',
    parent: tce
  });
  let footer = make('card-content', {
    contentType: 'paragraph-input',
    ident: 'tech-check-email--email-footer',
    defaultAnswerValue: 'the footer',
    parent: tce
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
  return [tc, intro, footer];
};

test(`it displays the 'Pass' label`, function(assert) {
  this.set('labelText', 'my label');
  this.render(template);
  assert.textPresent('.checked-label-text', 'Pass');
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);

  //create sendback data
  let tc = createCheckWithSendback()[0];

  this.set('content', tc);
  this.set('actionStub', function(newToggleVal) {
    assert.equal(newToggleVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('.card-content-toggle-switch input').click();
});

test(`toggling to 'Pass' will clear any existing sendbacks`, function(assert) {
  let [tc, sendbackCheck] = createCheckWithSendback();
  // check the box for the sendback
  make('answer', { owner: this.get('owner'), value: true, cardContent: sendbackCheck });

  $.mockjax({url: '/api/answers/1', type: 'PUT', status: 201, responseText: '{}'});

  this.set('content', tc);
  this.set('preview', false);
  this.render(template);

  assert.elementFound(
    `.sendback-reason-row input[type="checkbox"]:checked`,
    'the checkbox starts checked'
  );

  this.$('.card-content-toggle-switch input').click();
  return wait().then(() => {
    assert.mockjaxRequestMade({url: '/api/answers/1', type: 'PUT'}, 'it saves the sendback after clearing it');
    assert.elementNotFound(
      `.sendback-reason-row input[type="checkbox"]:checked`,
      'the checkbox becomes unchecked'
    );
  });
});

test(`checking a sendback will set the toggle to 'Fail' and send 'valueChanged'`, function(
  assert
) {
  assert.expect(4);
  let [tc, sendbackCheck] = createCheckWithSendback();
  // the sendback is unchecked
  make('answer', { owner: this.get('owner'), value: false, cardContent: sendbackCheck });
  // the tech check is set to 'Pass'
  let techCheckAnswer = make('answer', { owner: this.get('owner'), value: true, cardContent: tc });

  this.set('actionStub', function(newToggleVal) {
    assert.equal(
      newToggleVal,
      false,
      'it calls valueChanged with the new (false) toggle value after checking the sendback'
    );
  });
  this.set('content', tc);
  this.set('answer', techCheckAnswer);
  this.render(template);

  assert.elementFound(
    `.card-content-toggle-switch input:checked`,
    'the toggle is initially on'
  );

  this.$(`.sendback-reason-row input[type="checkbox"]`).click();

  assert.elementFound(
    `.sendback-reason-row input[type="checkbox"]:checked`,
    'the checkbox becomes checked'
  );
  assert.elementNotFound(
    `.card-content-toggle-switch input:checked`,
    'the switch gets toggled off'
  );
});

test(`tech check email preview`, function(assert) {
  let ds = make('card-content', {
    contentType: 'display-children'
  });
  let tc = make('card-content', {
    contentType: 'tech-check',
    valueType: 'boolean',
    parent: ds
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
    contentType: 'check-box',
    valueType: 'boolean',
    parent: sendback
  });
  let reason = make('card-content', {
    contentType: 'paragraph-input',
    parent: sendback
  });
  let tce = make('card-content', {
    contentType: 'tech-check-email',
    parent: ds
  });
  let intro = make('card-content', {
    contentType: 'paragraph-input',
    ident: 'tech-check-email--email-intro',
    defaultAnswerValue: 'the intro',
    parent: tce
  });
  let footer = make('card-content', {
    contentType: 'paragraph-input',
    ident: 'tech-check-email--email-footer',
    defaultAnswerValue: 'the footer',
    parent: tce
  });

  const owner = this.get('owner');
  const introText = 'im the intro';
  const footerText = 'im the footer';

  make('answer', { owner: owner, value: introText, cardContent: intro });
  make('answer', { owner: owner, value: footerText, cardContent: footer });

  make('answer', { owner: owner, value: 't', cardContent: checkbox });
  let reasonAnswer = make('answer', { owner: owner, value: '', cardContent: reason });

  $.mockjax({url: '/api/tasks/1/render_template', type: 'PUT', status: 201, responseText: '{"letter_template": {"body": "some text"}}'});

  this.set('content', ds);
  this.render(template);

  assert.elementNotFound(
    `.email-preview`, 'email preview is hidden by default'
  );

  this.$('.card-content-tech-check-email .button-primary').click();
  return wait().then(() => {
    assert.elementNotFound(
      `.email-preview`, 'email preview is not visible with empty sendbacks after clicking preview'
    );
    assert.elementFound(
      `.preview-error`, 'the preview error is now visible after clicking preview with empty sendbacks'
    );

    reasonAnswer.set('value', 'some text');

    this.$('.card-content-tech-check-email .button-primary').click();
    return wait().then(() => {
      assert.elementFound(
        `.email-preview`, 'email preview is visible after all checked sendbacks have values and button is clicked'
      );
      assert.equal($('.preview-content').text().trim(), 'some text', 'the preview displays the responses body');
      assert.elementFound(
        `.email-preview .button-primary`, 'email preview has a send email button'
      );
    });
  });
});

test(`submision diabled for non submitted state papers`, function(assert) {
  let [tc, intro, footer] = createCheckWithEmail();
  const introText = 'im the intro';
  const footerText = 'im the footer';
  this.set('owner.paper.publishingState', 'checking');

  make('answer', { owner: this.get('owner'), value: introText, cardContent: intro });
  make('answer', { owner: this.get('owner'), value: footerText, cardContent: footer });

  this.set('content', tc);
  this.render(template);

  assert.elementFound(
    '.card-content-tech-check-email .button-primary', 'email preview has a send email button'
  );

  this.$('.card-content-tech-check-email .button-primary').click();

  return wait().then(() => {
    assert.elementNotFound(
      `.email-preview`, 'email preview button is disabled'
    );
  });
});
