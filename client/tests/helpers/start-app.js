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
