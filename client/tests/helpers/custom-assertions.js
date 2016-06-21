import Ember from 'ember';
import QUnit from 'qunit';
import sinon from 'sinon';

// disable line-length linting for this file.
/* jshint -W101 */

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

  QUnit.assert.spyCalledWith = function(spy, args, message) {
    sinon.assert.calledWith(spy, ...args);
    return this.push(
      spy.calledWith(...args),
      spy.lastCall.args,
      args,
      message || `should've been called with args ${args}`);
  };

  QUnit.assert.selectorAttibuteIncludes = function(attribute, selector, values, message, expectedFoundElementsCount) {

    let elements = Ember.$(selector);
    let includesValues = _.map(elements, (element) => {
      _.include( Ember.$(element).attr(attribute), ...values);
    });

    // Optional feature, possibly pull out into it's own assertion.
    if (!_.isUndefined(expectedFoundElementsCount)){
      this.push(
        elements.length === expectedFoundElementsCount,
        elements.length,
        expectedFoundElementsCount,
        message + `Expected to find ${expectedFoundElementsCount} elements with selector ${selector}, but found ${elements.length}`
      );
    } else {
      this.ok(
        true,
        message + 'This assertion is to maintain the same amount of expected assertions');
    }

    let assertionMessage = message ? message : `Expected elements with selector ( ${selector} ) to have an attribute ( ${attribute} ) with value(s) ( ${values} ). Found ( ${elements.length} ) elements.`;
    let rejectedElementsFound = _.reject(includesValues).length;
    let expectedMessage = rejectedElementsFound === 0 ?
      'No elements found' :
      `${rejectedElementsFound} elements missing ( ${values} ).`;

    return this.push(
      rejectedElementsFound > 0,
      expectedMessage,
      `all elements to have ( ${values} ).`,
      assertionMessage
    );
  };

  QUnit.assert.selectorHasClasses = function() {
    return this.selectorAttibuteIncludes('class', ...arguments);
  };
}
