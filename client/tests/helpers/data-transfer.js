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
