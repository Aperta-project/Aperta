import Ember from 'ember';
import Application from '../../app';
import Router from '../../router';
import config from '../../config/environment';

import asyncHelpers from './async-helpers';
import storeHelpers from './store-helpers';
import containerHelpers from './container-helpers';
import chosenHelpers from './chosen-helpers';
import customAssertions from './custom-assertions';

import Factory from './factory';

export default function startApp(attrs) {
  var application;

  var attributes = Ember.merge({}, config.APP);
  attributes = Ember.merge(attributes, attrs); // use defaults, but you can override;

  Router.reopen({
    location: 'none'
  });

  var currentUser = Factory.createRecord('User', {
    id: 1,
    full_name: "Fake User",
    username: "fakeuser",
    email: "fakeuser@example.com"
  });

  window.currentUserData = {user: currentUser};

  Ember.run(function() {
    application = Application.create(attributes);
    application.setupForTesting();
    application.injectTestHelpers();
  });

  return application;
}
