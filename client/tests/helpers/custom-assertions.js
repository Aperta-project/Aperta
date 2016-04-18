import Ember from 'ember';
import QUnit from 'qunit';

export default function() {
  QUnit.assert.textPresent = function(selector, text, message) {
    let elementText  = Ember.$.trim(find(selector).text());
    let result       = elementText.indexOf(text) !== -1;
    let finalMessage;

    if(Ember.isEmpty(message)) {
      finalMessage = 'it should have text: ' + text + ' within ' + selector;
    } else {
      finalMessage = message;
    }

    return this.push(result, elementText, text, finalMessage);
  };

  QUnit.assert.textNotPresent = function(selector, text, message) {
    let elementText  = Ember.$.trim(find(selector).text());
    let result       = elementText.indexOf(text) === -1;
    let finalMessage;

    if(Ember.isEmpty(message)) {
      finalMessage = 'it should not have text: ' + text + ' within ' + selector;
    } else {
      finalMessage = message;
    }

    return this.push(result, elementText, text, finalMessage);
  };

  QUnit.assert.elementFound = function(selector, message) {
    const matches = $(selector).length;

    return this.push(matches === 1, `'${selector}' not found`, `found '${selector}'`, message || `should find element at ${selector}`);
  };

}
