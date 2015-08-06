import Ember from 'ember';

export default function() {
  Ember.Test.registerAsyncHelper('pickFromSelect2', function(app, scope, choice) {
    keyEvent(scope + '.select2-container input', 'keydown');
    fillIn(scope + '.select2-container input', choice);
    keyEvent(scope + '.select2-container input', 'keyup');
    waitForElement('.select2-result-selectable');
    return click('.select2-result-selectable', 'body');
  });
}
