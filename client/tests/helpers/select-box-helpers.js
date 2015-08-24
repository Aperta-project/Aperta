import Ember from 'ember';

export default function() {
  Ember.Test.registerAsyncHelper('pickFromSelectBox', function(app, scope, choice) {
    return click(scope + ' .select-box-element').then(function() {
      return click(scope + ' .select-box-item:contains(' + choice + ')');
    });
  });
}
