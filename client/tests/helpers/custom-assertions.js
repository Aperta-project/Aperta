import Ember from 'ember';
import QUnit from 'qunit';

// disable line-length linting for this file.
/* jshint -W101 */

export default function() {
  /**
   * despite its signature mockjaxRequestMade can take two types of
   * arguments: when called with (url, type, message) it will look
   * for a completed mockjax request with the given url and type, printing
   * the message if there isn't a match.
   *
   * The second form only takes two arguments: (matcher, message), where the
   * matcher is an object with keys that match the mockjax request's shape. For instance
   * assert.mockjaxRequestMade({url: '/foo', type: 'PUT', data: '{"update": true}'})
   * will find a PUT request to '/foo' with the specified data in the body.
   */
  QUnit.assert.mockjaxRequestMade = function(url, type, message){

    let actualDescription;
    let expectedDescription;

    let matcher;
    let actualDescriptionMapper;

    if (_.isObject(url)) {
      let matchDef = url;
      expectedDescription = `#{url}`;
      matcher = _.matches(matchDef);
      actualDescriptionMapper = (mockjaxCall) => {
        return _.pick(mockjaxCall, _.keys(matchDef));
      };

      // if url is an object, there will only be two arguments total and message will
      // be the second one
      message = arguments[1];
    } else {
      expectedDescription = `{ url: "${url}" type: "${type}"`;
      matcher = (mockjaxCall) => {
        return mockjaxCall.url === url && mockjaxCall.type === type;
      };
      actualDescriptionMapper = (mockjaxCall) => {
        return { url: mockjaxCall.url, type: mockjaxCall.type };
      };
    }

    if(!message){
      message = `Request to server was made thru $.mockjax: ${expectedDescription}`;
    }

    let mockjaxCalls = $.mockjax.mockedAjaxCalls();
    let requestFound = _.find(mockjaxCalls, matcher);

    if(!requestFound) {
      actualDescription = _.map(mockjaxCalls, actualDescriptionMapper);
    }

    return this.pushResult(
      requestFound,
      actualDescription,
      expectedDescription,
      message
    );
  };

  QUnit.assert.mockjaxRequestNotMade = function(url, type, message){
    let actualDescription;
    let expectedDescription = `{ url: "${url}" type: "${type}"`;

    if(!message){
      message = `Request to server was not made thru $.mockjax: ${expectedDescription}`;
    }

    let mockjaxCalls = $.mockjax.mockedAjaxCalls();
    let requestFound = _.find(mockjaxCalls, (mockjaxCall) => {
      return mockjaxCall.url === url && mockjaxCall.type === type;
    });

    if(requestFound) {
      actualDescription = _.map(mockjaxCalls, (mockjaxCall) => {
        return { url: mockjaxCall.url, type: mockjaxCall.type };
      });
    }

    return this.pushResult(
      !requestFound,
      actualDescription,
      expectedDescription,
      message
    );
  };

  QUnit.assert.arrayContainsExactly = function(actualArray, expectedArray, message){
    if(!message){
      message = `Expected array to contain the contents, but did not`;
    }

    let result = true;

    if(actualArray.length !== expectedArray.length){
      result = false;
    }
    if(_.intersection(actualArray, expectedArray).length !== expectedArray.length){
      result = false;
    }

    return this.pushResult(
      result,
      actualArray.invoke('toString'),
      expectedArray.invoke('toString'),
      message
    );
  };

  QUnit.assert.textPresent = function(selector, text, message) {
    let elementText  = Ember.$.trim(Ember.$(selector).text());
    let result       = elementText.indexOf(text) !== -1;
    let finalMessage;

    if(Ember.isEmpty(message)) {
      finalMessage = 'it should have text: ' + text + ' within ' + selector;
    } else {
      finalMessage = message;
    }

    return this.pushResult(result, elementText, text, finalMessage);
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

    return this.pushResult(result, elementText, text, finalMessage);
  };

  QUnit.assert.elementFound = function(selector, message) {
    const matches = $(selector).length;
    return this.pushResult({
      result: matches === 1,
      actual: matches,
      expected: 1 ,
      message: message || `should find single element at ${selector}`});
  };

  QUnit.assert.nElementsFound = function(selector, n, message) {
    const matches = $(selector).length;

    return this.pushResult({
      result: matches === n,
      actual: `found ${matches} '${selector}'s`,
      expected: `found ${n} '${selector}'s`,
      message: message || `should find ${n} elements at ${selector}`});
  };

  QUnit.assert.elementNotFound = function(selector, message) {
    const matches = Ember.$('#ember-testing ' + selector).length;
    return this.pushResult({
      result: matches === 0,
      actual: `'${selector}' found`,
      expected: `'${selector}' not found`,
      message: message || `should find no element at ${selector}`});
  };

  QUnit.assert.inputContains = function(selector, expectedValue) {
    selector = selector + ':input';

    this.elementFound(selector);
    var input  = Ember.$(selector);
    let value  = input.val();
    let result = value.indexOf(expectedValue) !== -1;

    return this.pushResult(
      result,
      value,
      expectedValue,
      `should find ${expectedValue} in input at ${selector}`);

  };

  QUnit.assert.inputPresent = function(selector, value, message) {
    selector = selector + ':input';
    var input = Ember.$(selector);

    this.elementFound(selector, message);

    return this.pushResult(
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

    return this.pushResult(
      input.is(':checked') === value,
      input.is(':checked'),
      value,
      message + '(wrong value found)' ||
        `should find ${value} in input at ${selector}`);
  };

  QUnit.assert.elementsFound = function(selector, count, message) {
    const matches = Ember.$(selector).length;

    return this.pushResult(matches === count, matches, count, message || `should find ${count} elements for ${selector}`);
  };

  QUnit.assert.spyCalledWith = function(spy, args, message) {
    if (!spy.called) {
      return QUnit.assert.spyCalled(spy, message);
    }

    return this.pushResult(
      spy.calledWith(...args),
      spy.lastCall.args,
      args,
      message || `should've been called with args ${args}`);
  };

  QUnit.assert.spyCalled = function(spy, message) {
    return this.pushResult(
      spy.called,
      'never called',
      'called',
      message || 'spy should have been called.');
  };

  QUnit.assert.spyNotCalled = function(spy, message) {
    return this.pushResult(
      spy.notCalled,
      'called',
      'not called',
      message || 'spy should not have been called.');
  };

  QUnit.assert.selectorAttibuteIncludes = function(attribute, selector, values, message, expectedFoundElementsCount) {

    let elements = Ember.$(selector);
    let includesValues = _.map(elements, (element) => {
      _.include( Ember.$(element).attr(attribute), ...values);
    });

    // Optional feature, possibly pull out into it's own assertion.
    if (!_.isUndefined(expectedFoundElementsCount)){
      this.pushResult(
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

    return this.pushResult(
      rejectedElementsFound > 0,
      expectedMessage,
      `all elements to have ( ${values} ).`,
      assertionMessage
    );
  };

  QUnit.assert.selectorHasClasses = function() {
    return this.selectorAttibuteIncludes('class', ...arguments);
  };

  QUnit.assert.arrayEqual = function(actual, expected) {
    const good =  {
      result: true,
      actual: actual,
      expected: expected,
      message: `equals: ${actual} and ${expected}`
    };
    if (actual === expected) { return this.pushResult(good); }
    if (actual.length !== expected.length) {
      return this.pushResult({
        result: false,
        actual: actual,
        expected: expected,
        message: `different lengths: ${actual} v. ${expected}`});
    }
    for (var i = 0; i < actual.length; ++i) {
      if (actual[i] !== expected[i]) {
        return this.pushResult({
          result: false,
          actual: actual,
          expected: expected,
          message: `element ${i} of ${actual} did not match ${expected}`});
      }
    }
    return this.pushResult(good);
  };
}
