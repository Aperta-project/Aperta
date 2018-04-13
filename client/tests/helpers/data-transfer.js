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

// Shamelessly taken from the https://github.com/mharris717/ember-drag-drop addon
//
// ****Usage example in tests********
// let event = MockDataTransfer.makeMockEvent();
//  let $component = this.$('.draggable-object');
//
// Ember.run(function() {
//   triggerEvent($component, 'dragstart', event);
// });
//
// assert.equal($component.hasClass('is-dragging-object'), true);
// ******end usage example
import Ember from 'ember';

var c = Ember.Object.extend({
  getData: function() {
    return this.get('payload');
  },

  setData: function(dataType,payload) {
    this.set('data', {dataType: dataType, payload: payload});
  }
});

c.reopenClass({
  makeMockEvent: function(payload) {
    var transfer = this.create({payload: payload});
    var res = {dataTransfer: transfer};
    res.originalEvent = res;
    res.originalEvent.preventDefault = function() {
      //no-op
    };
    res.originalEvent.stopPropagation = function() {
      //no-op
    };
    return res;
  },

  createDomEvent: function(type) {
    var event = document.createEvent('CustomEvent');
    event.initCustomEvent(type, true, true, null);
    event.dataTransfer = {
      data: {},
      setData: function(type, val){
        this.data[type] = val;
      },
      getData: function(type){
        return this.data[type];
      }
    };
    return event;
  }
});

export default c;
