import Ember from 'ember';
import Application from '../../app';
import Router from '../../router';
import config from '../../config/environment';

import registerCustomAssertions from './custom-assertions';
import registerAsyncHelpers     from './async-helpers';
import regsiterStoreHelpers     from './store-helpers';
import registerContainerHelpers from './container-helpers';
import registerSelectHelpers    from './select-native-helper';
import registerSelect2Helpers   from './select2-helpers';
import registerSelectBoxHelpers from './select-box-helpers';

import Factory from './factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import HtmlEditorController from 'tahi/pods/paper/index/html-editor/controller';

registerCustomAssertions();
registerAsyncHelpers();
regsiterStoreHelpers();
registerContainerHelpers();
registerSelectHelpers();
registerSelect2Helpers();
registerSelectBoxHelpers();


export default function startApp(attrs) {
  let application;

  let attributes = Ember.merge({}, config.APP);
  attributes = Ember.merge(attributes, attrs); // use defaults, but you can override;

  Router.reopen({
    location: 'none'
  });

  let currentUser = Factory.createRecord('User', {
    id: 1,
    fullName: 'Fake User',
    username: 'fakeuser',
    email: 'fakeuser@example.com'
  });

  window.currentUserData = {user: currentUser};

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
    }
  });

  // Note: use a mock component for testing
  HtmlEditorController.reopen({
    editorComponent: 'mock-html-editor',
  });

  Ember.run(function() {
    application = Application.create(attributes);
    application.setupForTesting();
    application.injectTestHelpers();
  });

  return application;
}
