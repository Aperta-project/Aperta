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
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleForComponent(
  'card-content/display-children',
  'Integration | Component | card content | display children',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
      this.set('repetition', null);
      this.set('owner', Ember.Object.create());
      this.set('preview', false);
    }
  }
);

let template = hbs`
{{card-content/display-children
  class="display-test"
  owner=owner
  disabled=disabled
  repetition=repetition
  preview=preview
  content=content}}`;

let fakeTextContent = Ember.Object.extend({
  contentType: 'text',
  text: 'A piece of card content',
  answerForOwner() {
    return { value: 'foo' };
  }
});

test(`when disabled, it marks its children as disabled`, function(assert) {
  let content = fakeTextContent.create({
    children: [
      FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Child 1'
      })
    ]
  });
  this.set('content', content);
  this.set('disabled', true);
  this.render(template);
  assert.elementFound(
    '.card-content-short-input input:disabled',
    'found disabled short input'
  );
});

test(`when wrapperTag is present ('tagless'), the custom class doesn't appear`, function(assert) {
  let content = FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Child 1',
        wrapperTag: null,
        customClass: 'pretty-colors'
  });
  this.set('content', content);
  this.render(template);
  assert.elementNotFound(
    '.pretty-colors',
    'custom class not visible'
  );
});

test(`when wrapperTag is present, the custom class appears on the wrapper element`, function(assert) {
  let content = FactoryGuy.make('card-content', {
    contentType: 'short-input',
    text: 'Child 1',
    wrapperTag: 'ol',
    customClass: 'pretty-colors'
  });
  this.set('content', content);
  this.render(template);
  assert.elementFound(
    'ol.pretty-colors',
    'custom class and element visible'
  );
});
