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
import { test, moduleForModel } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';
import sinon from 'sinon';


var app = null;
moduleForModel('task-template','Unit: Task Template Model', {
  beforeEach: function() {
    app = startApp();
  },
  afterEach: function() {
    Ember.run(app, app.destroy);
  }
});

test('settings should be an ember array with ember objects', function(assert) {
  let taskTemplate = FactoryGuy.make('task-template');
  Ember.run(() => { taskTemplate.set('allSettings', [{name: 'foo', value: 'bar'}]); });

  assert.equal(Ember.typeOf(taskTemplate.get('settings')), 'array');
  assert.equal(taskTemplate.get('settings').findBy('name', 'foo').get('value'), 'bar');
});

test('settingComponents should return mapped component', function(assert) {
  let taskTemplate = FactoryGuy.make('task-template');
  Ember.run(() => { taskTemplate.set('allSettings', [{name: 'review_duration_period', value: 10}]); });

  assert.ok(taskTemplate.get('settingComponents').indexOf('invite-reviewers-settings') >= 0);
});

test('updateSetting should make API call and update object', function(assert) {
  assert.expect(2);
  let fakeRestless = {
    put: sinon.stub()
  };
  fakeRestless.put.returns(Ember.RSVP.Promise.resolve('Success'));
  const settingName = 'review_duration_period';
  let taskTemplate = FactoryGuy.make('task-template');
  Ember.run(() => {
    taskTemplate.set('restless', fakeRestless);
    taskTemplate.set('allSettings', [{name: settingName, value: 10}]);
    taskTemplate.updateSetting(settingName, 20).then(() => {
      assert.equal(taskTemplate.get('settings').findBy('name', settingName).get('value'), 20);
    });
  });

  const putArgs = [
    `/api/task_templates/${taskTemplate.get('id')}/update_setting`,
    {
      'name': settingName,
      'value': 20
    }
  ];
  assert.spyCalledWith(fakeRestless.put, putArgs, 'Calls restless with update setting endpoint');
});
