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
import Application from 'tahi/app';
import Router from 'tahi/router';
import config from 'tahi/config/environment';
import * as TestHelper from 'ember-data-factory-guy';

import registerPowerSelectHelpers from 'tahi/tests/helpers/ember-power-select';

import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import registerAsyncHelpers     from 'tahi/tests/helpers/async-helpers';
import registerStoreHelpers     from 'tahi/tests/helpers/store-helpers';
import registerContainerHelpers from 'tahi/tests/helpers/container-helpers';
import registerSelectHelpers    from 'tahi/tests/helpers/select-native-helper';
import registerSelect2Helpers   from 'tahi/tests/helpers/select2-helpers';

import Factory from 'tahi/tests/helpers/factory';

registerPowerSelectHelpers();
registerCustomAssertions();
registerAsyncHelpers();
registerStoreHelpers();
registerContainerHelpers();
registerSelectHelpers();
registerSelect2Helpers();


export default function startApp(attrs) {
  let application;

  let attributes = Ember.merge({}, config.APP);
  attributes = Ember.merge(attributes, attrs); // use defaults, but you can override;

  Router.reopen({
    location: 'none'
  });

  let orcidAccount = Factory.createRecord('OrcidAccount', {
    id: 1
  });

  let currentUser = Factory.createRecord('User', {
    id: 1,
    first_name: 'Fake',
    last_name: 'User',
    fullName: 'Fake User',
    username: 'fakeuser',
    email: 'fakeuser@example.com'
  });

  window.currentUserData = {
    user: currentUser,
    orcid_accounts: [orcidAccount]
  };

  window.eventStreamConfig = {
    key: 'fakeAppKey123456',
    host: 'localhost',
    port: '59198',
    auth_endpoint_path: '/event_stream/auth'
  };

  TestHelper.mockPaperQuery = (paper) => {
    let mockedQuery = TestHelper.mockQuery('paper').returns({models: [paper]});
    var shortDoi = Ember.get(paper, 'shortDoi');
    mockedQuery.getUrl = function() { return `/api/papers/${shortDoi}`; };
    return mockedQuery;
  };

  $.mockjax({
    url: '/api/feature_flags',
    method: 'GET',
    status: 200,
    responseText: {'feature_flags':[]}
  });

  Ember.run(() => {
    application = Application.create(attributes);
    application.setupForTesting();
    application.injectTestHelpers();
  });

  $.mockjax({url: /\/api\/notifications\/?/, status: 204});

  return application;
}
