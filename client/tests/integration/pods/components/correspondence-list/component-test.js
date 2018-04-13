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

import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';
import formatDate from 'tahi/lib/aperta-moment';


moduleForComponent('correspondence', 'Integration | Component | Correspondence', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    $.mockjax({
      type: 'GET',
      url: '/api/notifications/',
      status: 200,
      responseText: {}
    });
  },

  afterEach() {
    $.mockjax.clear();
  }
});

let template = hbs`
  <div id="mobile-nav"></div>
  {{correspondence-list model=correspondence paper=paper}}
`;

test('can manage workflow, list appears for correspondence with manuscript version and status', function(assert) {
  let paper = FactoryGuy.make('paper', { publishingState: 'submitted', firstSubmittedAt: '2016-09-28T13:54:58.028Z'});
  let correspondence = FactoryGuy.make('correspondence', { paper: paper });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table').length, 1);
    assert.equal(this.$('tbody').length, 1);
    assert.textPresent('tr:last td:nth-child(1)', formatDate(correspondence.get('utcSentAt'), {}));
    assert.textPresent('tr:last td:nth-child(2)', correspondence.get('subject'));
    assert.textPresent('tr:last td:nth-child(3)', correspondence.get('recipient'));
    assert.equal(this.$('tr:last td:nth-child(4)').length, 1, 'v0.0 rejected');
    assert.textPresent('tr:last td:nth-child(5)', correspondence.get('sender'));
    assert.textPresent('.correspondence-table > p', 'Correspondence sent before February 1, 2017 is not available for display.');
  });
});

test('can manage workflow, list appears for correspondence without manuscript version and status', function(assert) {
  let paper = FactoryGuy.make('paper');
  let correspondence = FactoryGuy.make('correspondence', { paper: paper });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table .most-recent-activity').length, 0);
    assert.equal(this.$('.correspondence-table').length, 1);
    assert.equal(this.$('tbody').length, 1);
    assert.textPresent('tr:last td:nth-child(1)', formatDate(correspondence.get('utcSentAt'), {}));
    assert.textPresent('tr:last td:nth-child(2)', correspondence.get('subject'));
    assert.textPresent('tr:last td:nth-child(3)', correspondence.get('recipient'));
    assert.equal(this.$('tr:last td:nth-child(4)').length, 1, 'Unavailable');
    assert.textPresent('tr:last td:nth-child(5)', correspondence.get('sender'));
    assert.equal(this.$('.correspondence-table > p').length, 0);
  });
});

test('can manage workflow, for correspondence with only manuscript version', function(assert) {
  let paper = FactoryGuy.make('paper', { publishingState: 'submitted' });
  let correspondence = FactoryGuy.make('correspondence', { paper: paper, manuscriptStatus: null });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table').length, 1);
    assert.equal(this.$('tbody').length, 1);
    assert.textPresent('tr:last td:nth-child(1)', formatDate(correspondence.get('utcSentAt'), {}));
    assert.textPresent('tr:last td:nth-child(2)', correspondence.get('subject'));
    assert.textPresent('tr:last td:nth-child(3)', correspondence.get('recipient'));
    assert.equal(this.$('tr:last td:nth-child(4)').length, 1, 'v0.0');
    assert.textPresent('tr:last td:nth-child(5)', correspondence.get('sender'));
  });
});

test('can not manage workflow, list is hidden', function(assert) {
  let paper = FactoryGuy.make('paper');
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table').length, 0);
  });
});

test('correspondence with activities show the activity atop the entry', function(assert) {
  let paper = FactoryGuy.make('paper');
  let correspondence = FactoryGuy.make('correspondence', 'externalCorrespondence', {
    activities: [
      { key: 'correspondence.created', full_name: 'Jim', created_at: '1989-8-19' }
    ],
    paper: paper
  });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);

  return wait().then(() => {
    assert.textPresent('.correspondence-table .most-recent-activity', 'Added by Jim');
  });
});

test('deleted correspondence renders deleted view of list items', function(assert) {
  let paper = FactoryGuy.make('paper');
  let correspondence = FactoryGuy.make('correspondence', 'externalCorrespondence', {
    status: 'deleted',
    activities: [
      { key: 'correspondence.deleted', full_name: 'Jim', created_at: '1989-8-19' }
    ],
    paper: paper
  });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);

  return wait().then(() => {
    assert.textPresent('tr:last td:nth-child(2)', 'view details');
    assert.textPresent('tr:last td:nth-child(3)', 'n.a.');
    assert.equal(this.$('tr:last td:nth-child(4)').length, 1, 'n.a.');
    assert.textPresent('tr:last td:nth-child(5)', 'n.a.');
  });
});
