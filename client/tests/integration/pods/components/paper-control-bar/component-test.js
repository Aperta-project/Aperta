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
import stubRouteAction from 'tahi/tests/helpers/stub-route-action';
import Ember from 'ember';


let paper, showActivity;
const template = hbs`
  <div id="mobile-nav"></div>
  {{paper-control-bar paper=paper tab="manuscript" showActivity=showActivity}}
`;

moduleForComponent('paper-control-bar', 'Integration | Component | Paper Control Bar', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    let routeActions = {
      showOrRaiseDiscussions(arg) {
        return Ember.RSVP.resolve({arg});
      }
    };
    stubRouteAction(this.container, routeActions);
    $.mockjax({
      type: 'GET',
      url: '/api/notifications/',
      status: 200,
      responseText: {}
    });
    paper = FactoryGuy.make('paper');
    this.set('paper', paper);
    showActivity = function() {};
    this.set('showActivity', showActivity);
  },
  afterEach() {
    $.mockjax.clear();
  }
});


test('can manage workflow, all icons show', function(assert) {
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-correspondence').length, 1);
    assert.equal(this.$('#nav-workflow').length, 1);
    assert.equal(this.$('#nav-manuscript').length, 1);
  });
});


test('can not manage workflow, correspondence enabled, no nav icons', function(assert) {
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-correspondence').length, 0);
    assert.equal(this.$('#nav-workflow').length, 0);
    assert.equal(this.$('#nav-manuscript').length, 0);
  });
});

test('can view recent activity, sees recent activity nav icon', function(assert) {
  const can = FakeCanService.create().allowPermission('view_recent_activity', paper);
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-recent-activity').length, 1);
  });
});

test('can not view recent activity, no recent activity nav icon', function(assert) {
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-recent-activity').length, 0);
  });
});

test('Toggling Collaborators from paper index does not throw an error', function(assert) {
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-collaborators').length, 1);
    this.$('#nav-collaborators').click();
    assert.ok(this.$('#nav-collaborators').click());
  });
});
