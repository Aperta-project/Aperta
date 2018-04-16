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

import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import { createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import * as TestHelper from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'author-form-coauthor-controls',
  'Integration | Component | author-form-coauthor-controls',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
      registerCustomAssertions();
      let journal = FactoryGuy.make('journal');
      TestHelper.mockFindRecord('journal').returns({model: journal});
      //
      let user = FactoryGuy.make('user');
      let author = FactoryGuy.make('author', { user: user });
      let paper = FactoryGuy.make('paper');
      //
      this.set('author', author);
      this.set('author.paper', paper);
      this.set('author.paper.journal', 1);
      this.set('isNotEditable', false);
      this.set('actions', { selectAuthorConfirmation: (status) => {
        this.set('selectedStatus', status);
      }});

    }
  }
);

var template = hbs`
  {{author-form-coauthor-controls
          author=author
          disabled=isNotEditable
          setConfirmation=(action "selectAuthorConfirmation")
  }}`;

test("component shows author is confirmed", function(assert) {
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'confirmed');
  });
  this.render(template);
  assert.textPresent('.author-confirmed', 'Authorship has been confirmed');
});

test("component shows author is refuted", function(assert) {
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'refuted');
  });
  this.render(template);
  assert.textPresent('.author-refuted', 'Authorship has been refuted');
});

test("component shows author is unconfirmed", function(assert) {
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'unconfirmed');
  });
  this.render(template);
  const expectedMessage = 'When you submit your manuscript, an email will be sent to this coauthor at the address you provide below to confirm authorship';

  assert.textPresent('.author-coauthor-info', expectedMessage);
});

test("clicking the radio buttons fire an action with the radio button value", function(assert) {
  assert.expect(3);
  this.render(template);

  this.$("[data-test-selector='confirm-authorship']").click();
  assert.equal(this.get('selectedStatus'), 'confirmed');
  this.$("[data-test-selector='refute-authorship']").click();
  assert.equal(this.get('selectedStatus'), 'refuted');
  this.$("[data-test-selector='unconfirm-authorship']").click();
  assert.equal(this.get('selectedStatus'), 'unconfirmed');
});
