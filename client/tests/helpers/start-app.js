import Ember from 'ember';
import Application from '../../app';
import Router from '../../router';
import config from '../../config/environment';

import registerPowerSelectHelpers from '../../tests/helpers/ember-power-select';

import registerCustomAssertions from './custom-assertions';
import registerAsyncHelpers     from './async-helpers';
import registerStoreHelpers     from './store-helpers';
import registerContainerHelpers from './container-helpers';
import registerSelectHelpers    from './select-native-helper';
import registerSelect2Helpers   from './select2-helpers';

import Factory from './factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

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

  TestHelper.reopen({
    mapFind: function(modelName, json) {
      let responseJson = {};
      // hack to work around
      // https://github.com/danielspaniel/ember-data-factory-guy/issues/82
      if ((/Task/).test(modelName)) {
        modelName = 'task';
      }
      responseJson[Ember.String.pluralize(modelName)] = json;
      return responseJson;
    },
    mockPaperQuery: function(paper) {
      let mockedQuery = this.mockQuery('paper').returns({models: [paper]});
      var shortDoi = Ember.get(paper, 'shortDoi');
      mockedQuery.getUrl = function() { return `/api/papers/${shortDoi}`; };
      return mockedQuery;
    }
  });

  Ember.run(() => {
    application = Application.create(attributes);
    application.setupForTesting();
    application.injectTestHelpers();
  });

  $.mockjax({url: /\/api\/notifications\/?/, status: 204});

  return application;
}
