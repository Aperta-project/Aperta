import Ember from 'ember';

export default function() {
  Ember.Test.registerHelper('getStore', function(app) {
    return app.__container__.lookup('service:store');
  });

  Ember.Test.registerHelper('getCurrentUser', function(app) {
    return app.__container__.lookup('user:current');
  });
}
