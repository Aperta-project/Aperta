import Ember from 'ember';

export default function() {
  Ember.Test.registerHelper('getContainer', function(app) {
    return app.__container__;
  });
}
