import Ember from 'ember';

export default function() {
  Ember.Test.registerHelper('pushModel', function(app, type, data) {
    let store = app.__container__.lookup('store:main');
    return Ember.run(function() {
      store.push(type, data);
      return store.getById(type, data.id);
    });
  });

  Ember.Test.registerHelper('pushPayload', function(app, type, data) {
    let store = app.__container__.lookup('store:main');
    return Ember.run(function() {
      return store.pushPayload(type, data);
    });
  });

  Ember.Test.registerHelper('getStore', function(app) {
    return app.__container__.lookup('store:main');
  });

  Ember.Test.registerHelper('getCurrentUser', function(app) {
    return app.__container__.lookup('user:current');
  });
}
