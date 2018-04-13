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
import { module, test } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';

var app = null;
module('Unit: Author Model', {
  beforeEach: function() {
    app = startApp();
  },
  afterEach: function() {
    Ember.run(app, app.destroy);
  }
});

test('#Affiliations', function(assert) {
  let author = FactoryGuy.make('author', {affiliation: 'ABC', secondAffiliation: null});
  assert.equal(author.get('affiliations'), 'ABC', 'returns the first affiliation without any character appended at the end');
  let author_two = FactoryGuy.make('author', {affiliation: 'QAZ', secondaryAffiliation: 'WSX'});
  assert.equal(author_two.get('affiliations'), 'QAZ, WSX', 'returns both affiliations joined by a comma');
});

test('#fullNameWithAffiliations', function(assert) {
  let author = FactoryGuy.make('author', {affiliation: 'ABC', secondAffiliation: null});
  assert.equal(author.get('fullNameWithAffiliations'), `${author.get('displayName')}, ABC`, 'returns full name with affiliations when the latter exist');
  let author_two = FactoryGuy.make('author');
  assert.equal(author_two.get('fullNameWithAffiliations'), `${author_two.get('displayName')}`, 'returns only full name if author does not have affiliations');
});
