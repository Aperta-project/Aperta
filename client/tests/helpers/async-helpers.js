import Ember from 'ember';

export default function() {
  return Ember.Test.registerAsyncHelper('waitForElement', function(app, element) {
    return Ember.Test.promise(function(resolve) {
      Ember.Test.adapter.asyncStart();
      let interval = window.setInterval(function() {
        if ($(element).length > 0) {
          window.clearInterval(interval);
          Ember.Test.adapter.asyncEnd();
          Ember.run(null, resolve, true);
        }
      }, 10);
    });
  });
}
