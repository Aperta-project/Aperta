import Ember from 'ember';
import QUnit from 'qunit';

export default function() {
  QUnit.assert.textPresent = function(selector, text, message) {
    let elementText  = Ember.$.trim(Ember.$(selector).text());
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
    let elementText  = Ember.$.trim(Ember.$(selector).text());
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

    return this.push(
      matches === 1,
      `one '${selector}' not found`,
      `found ${matches} '${selector}'s`,
      message || `should find single element at ${selector}`);
  };

  QUnit.assert.elementNotFound = function(selector, message) {
    const matches = Ember.$('#ember-testing ' + selector).length;
    return this.push(
      matches === 0,
      `'${selector}' found`,
      `'${selector}' not found`,
      message || `should find no element at ${selector}`);
  };

  QUnit.assert.inputPresent = function(selector, value, message) {
    selector = selector + ':input';
    var input = Ember.$(selector);

    this.elementFound(selector, message);

    return this.push(
      input.val() === value,
      input.val(),
      value,
      message + '(wrong value found)' ||
        `should find ${value} in input at ${selector}`);

  };

  QUnit.assert.checkboxPresent = function(selector, value, message) {
    selector = selector + ':checkbox';
    var input = Ember.$(selector);

    this.elementFound(selector, message);

    return this.push(
      input.is(':checked') === value,
      input.is(':checked'),
      value,
      message + '(wrong value found)' ||
        `should find ${value} in input at ${selector}`);
  };

  QUnit.assert.elementsFound = function(selector, count, message) {
    const matches = Ember.$(selector).length;

    return this.push(matches === count, matches, count, message || `should find ${count} elements for ${selector}`);
  };
}
