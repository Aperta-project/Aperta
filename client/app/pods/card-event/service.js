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

