import Ember from 'ember';

/**
  Adds a `busyWhile` method to a class that is used to set a `busy` attribute on
  an instance while a promise is running.

  Example usage:

  ```javascript
  Component.extend(HasBusyStateMixin, {
    classNameBindings: ['busy:show-spinner'],

    actions: {
      saving() {
        this.busyWhile(model.save());
      },
    }
  }
  ```
  @extends Ember.Mixin
  @class HasBusyStateMixin
*/
export default Ember.Mixin.create({
  busy: false,

  /**
    Sets `busy` attribute to `true`, then returns a promise that will set the
    `busy` attribute to false after the provided `promise` param resolves.

    @method busyWhile
    @param {Ember.RSVP.Promise} promise A promise during the execution of which
      the `busy` attribute will be set to true.
    @return {Ember.RSVP.Promise} A promise that resolves after the `busy` attribute has been set to `false`
  */
  busyWhile(promise) {
    let setBusy = new Ember.RSVP.Promise((resolve) => {
      this.set('busy', true);
      resolve();
    });
    return Ember.RSVP.all([setBusy, promise]).finally(()=> { this.set('busy', false); } );
  }
});
