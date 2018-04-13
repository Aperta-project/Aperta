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
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'figure-task',
  'Integration | Components | Tasks | figure thumbnail', {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);
      this.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
    },
    afterEach() {
      $.mockjax.clear();
    }
  }
);

let template = hbs`{{figure-thumbnail isEditable=true figure=figure destroyFigure=(action destroyFigure)}}`;

test('it renders stuff when status is done', function(assert) {
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'done', title: 'My Title'}));
  this.render(template);

  assert.textPresent('.title', 'My Title', 'renders the title');
});

test('it renders a progress message while processing', function(assert) {
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'processing'}));
  this.render(template);
  assert.elementFound('.progress-text', 'shows the progress message');
});

test('it renders an error state', function(assert) {
  let done = assert.async();
  assert.expect(2);

  this.set('figure', make('figure', {status: 'error'}));
  this.set('destroyFigure', function() {
    assert.ok(true, 'destroyFigure action is invoked');
    done();
  });

  this.render(template);
  assert.elementFound('.progress-error', 'shows an error message');

  this.$('.upload-cancel-button').click();
});

test('it allows the user to cancel', function(assert) {
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'processing'}));
  $.mockjax({url: '/api/figures/1/cancel', type: 'PUT', status: 204});
  this.render(template);

  this.$('.upload-cancel-link').click();

  assert.textPresent('.progress-text','Upload canceled. Re-upload to try again', 'shows cancel message');
});

test('it sets figure title to \'Fig [rank]\' on input', function(assert) {
  let newRank = 5;
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'done', title: 'Fig 2'}));
  this.render(template);
  this.$('.fa-pencil').click();
  this.$('input[type=number]').val(newRank).trigger('input');
  assert.equal(this.get('figure.title'), 'Fig ' + newRank);
});
