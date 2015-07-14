import Ember from 'ember';
import QUnit from 'qunit';

export default function() {
  QUnit.assert.textPresent = function(selector, text, message) {
    let elementText  = Ember.$.trim(find(selector).text());
    let result       = elementText.indexOf(text) !== -1;
    let finalMessage = Ember.isEmpty(message) ? ('it should have text: ' + text + ' within ' + selector) : message;

    return this.ok(result, finalMessage);
  };

  QUnit.assert.textNotPresent = function(selector, text, message) {
    let elementText  = Ember.$.trim(find(selector).text());
    let result       = elementText.indexOf(text) === -1;
    let finalMessage = Ember.isEmpty(message) ? ('it should not have text: ' + text + ' within ' + selector) : message;

    return this.ok(result, finalMessage);
  };
}
