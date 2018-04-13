/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';

/**
 * the event listener takes care of the boilerplate for registering and unregistering
 * listeners.
 * client components need to provide a cardEvents object whose keys are the names of events
 * and whose values are strings representing a function name to call when that event is fired.
 *
 * ex:
 * Ember.Component.extend(CardEventListener, {
 *   cardEvents: {
 *   onFoo: 'bar'
 *   },
 *
 *   bar(eventPayload) {
 *     console.log('payload');
 *   }
 * })
 *
 * In this example when the cardEventService triggers 'onFoo' the 'bar' function in the component will be called
 */
let CardEventListener = Ember.Mixin.create({
  cardEvent: Ember.inject.service(),

  didInsertElement() {
    this._super(...arguments);
    let cardEvents = this.get('cardEvents');
    let service = this.get('cardEvent');

    _.forEach(cardEvents, (functionName, eventName) => {
      service.on(eventName, this, functionName);
    });
  },

  willDestroyElement() {
    this._super(...arguments);
    let cardEvents = this.get('cardEvents');
    let service = this.get('cardEvent');

    _.forEach(cardEvents, (functionName, eventName) => {
      service.off(eventName, this, functionName);
    });
  }
});

export { CardEventListener };
export default Ember.Service.extend(Ember.Evented);
