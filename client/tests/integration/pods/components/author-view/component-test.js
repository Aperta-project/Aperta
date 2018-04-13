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

import Ember from 'ember';
import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'author-view',
  'Integration | Component | author-view',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);

      $.mockjax({url: '/api/countries', status: 200, responseText: {
        countries: [],
      }});
      $.mockjax({url: '/api/institutional_accounts', status: 200, responseText: {
        institutional_accounts: [],
      }});

      let journal = FactoryGuy.make('journal', {
        coauthorConfirmationEnabled: true
      });

      let paper = FactoryGuy.make('paper', {
        journal: journal
      });

      let authorsTask = FactoryGuy.make('authors-task');
      let author = FactoryGuy.make('author', {paper: paper});
      let user = FactoryGuy.make('user');

      author.set('displayName', 'Bob Smith');

      this.set('author', author);
      this.set('currentUser', user);
      this.set('isEditable', true);
      this.set('isNotEditable', false);
      this.set('model', {object: author});
      this.set('task', authorsTask);
    }
  }
);

var template = hbs`
  {{
    author-view
      currentUser=currentUser
      task=task
      model=model
      isEditable=isEditable
      isNotEditable=isNotEditable
      delete="removeAuthor"
  }}`;

test("component lists the author", function(assert){
  this.render(template);

  assert.textPresent('.author-task-item-view .author-name', 'Bob Smith');
  assert.textNotPresent('.author-task-item-view .author-name', '(you)');
});

test("component lists the author when they are the current user", function(assert){
  Ember.run( () => {
    this.get('author').set('user', this.get('currentUser'));
  });
  this.render(template);
  assert.textPresent('.author-task-item-view .author-name', 'Bob Smith (you)');
});

test("component shows author is unconfirmed", function(assert){
  this.render(template);
  // The author's name should be the only text present
  assert.textPresent('[data-test-selector="author-task-item-view-text"]', 'Bob Smith');
});

test('component shows author is confirmed if co author conf is on', function(assert){
  Ember.run( () => {
    this.get('author').set('coAuthorState', 'confirmed');
  });
  this.render(template);
  assert.textPresent('[data-test-selector="author-confirmed"]', 'Confirmed');

  Ember.run( () => {
    this.get('author.paper.journal').set('coauthorConfirmationEnabled', false);
  });

  assert.elementNotFound('[data-test-selector="author-confirmed"]');
});

test('component shows author is refuted', function(assert){
  Ember.run( () => {
    this.get('author').set('coAuthorState', 'refuted');
  });
  this.render(template);
  assert.textPresent('[data-test-selector="author-refuted"]', 'Refuted');
});
