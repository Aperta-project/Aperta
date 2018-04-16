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
import { make, manualSetup }  from 'ember-data-factory-guy';
import Ember from 'ember';
import { clickTrigger } from 'tahi/tests/helpers/ember-power-select';

moduleForComponent('manuscript-new', 'Integration | Component | manuscript new', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
  }
});

test('it renders article types in the correct order', function(assert) {
  const paperTypeNames = ['Pickachu', 'Research Article', 'Bulbasaur', 'Methods and Resources'];
  const expectedOrder = ['Research Article', 'Methods and Resources', 'Bulbasaur', 'Pickachu'];
  const manuscriptManagerTemplates = Ember.A($.map(paperTypeNames, (n) => {
    return {paper_type: n};
  }));
  this.paper = make('paper', { journal: { manuscriptManagerTemplates }});
  this.render(hbs`{{manuscript-new paper=paper}}`);
  clickTrigger('#paper-new-paper-type-select');
  const options = $('.ember-power-select-option');
  const values = $.map(options, (o) => { return o.textContent.trim(); });
  assert.deepEqual(values, expectedOrder);
});
