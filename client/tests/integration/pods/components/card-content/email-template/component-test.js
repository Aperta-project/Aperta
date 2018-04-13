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
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'card-content/email-template',
  'Integration | Component | card content | email-template',
  {
    integration: true,

    beforeEach() {
      this.set('owner', Ember.Object.create({ id: 1 }));
      this.set('content', Ember.Object.create({ letterTemplate: 'test', ident: 'test' }));
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

const template = hbs`{{card-content/email-template
content=content
owner=owner
}}`;

const templateJSON = '{"letter_template": {"body": "<p>test</p>"}}';

test(`it displays the body of the template as markup`, function(assert) {
  $.mockjax({url: '/api/tasks/1/render_template', type: 'PUT', status: 201, responseText: templateJSON});
  this.render(template);
  assert.elementFound('.card-content-template');

  return wait().then(() => {
    assert.textPresent('.card-content-template p', 'test');
    assert.textNotPresent('.card-content-template p', '<p>test</p>');
  });
});
