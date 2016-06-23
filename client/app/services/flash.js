import Ember from 'ember';
import prepareResponseErrors from 'tahi/lib/validations/prepare-response-errors';

/**
  ## How to Use

  Anywhere in your template:

  ```
  {{flash-messages}}
  ```

  If you need a custom class wrapped around your messages:

  ```
  {{flash-messages classNames="custom-classes-here"}}
  ```

  ### In your Route or Controller from an Ember Data save:

  ```
  actions: {
    save() {
      this.get('model').save().then(
        function() {},
        (response)=> {
          this.flash.displayErrorMessagesFromResponse(response);
        }
      );
    }
  }
  ```

  To set a message manually from Controller or Route:

  ```
  this.flash.displayMessage('success', 'You win');
  ```

  The messages will be cleared out on the next route transition or overlay close.
  If you need to clear them out manually:

  ```
  this.flash.clearAllMessages();
  ```

  ## How it Works

  A service is created and injected into all Routes and Controllers
  from an Ember Initializer as the property `flash`.
  When `displayMessage` or `displayErrorMessagesFromResponse` is called, all
  we're doing is pushing to an array of messages that are displayed in the templates.
  The `flash` object is also injected into the `flash-messages` component.
*/

export default Ember.Service.extend({
  /**
    @property messages
    @type Array
    @default []
  */
  messages: [],

  /**
    Create a single message.

    ```
    this.flash.displayMessage('error', 'Oh noes');
    ```

    @method displayMessage
    @param {String} type    Used to generate final class. Example: `flash-message--success`
    @param {String} message Message displayed to user
  */

  displayMessage(type, message) {
    this.get('messages').pushObject({
      text: message,
      type: type
    });
  },

  /**
    The array of messages for each key under `errors` will be joined into a single string, separated by comma.
    ```
    {
      errors: {
        name: ['is too short', 'is invalid']
      }
    }
    ```

    "Name is too short, is invalid"

    @method displayErrorMessagesFromResponse
    @param {Object} response Hash from Ember Data `save` failure. Expected to be in format Rails sends.
  */

  displayErrorMessagesFromResponse(response) {
    this.clearAllMessages();
    let errors = prepareResponseErrors(response.errors, ({includeNames: 'humanize'}));

    Object.keys(errors).forEach((key) => {
      let msg = errors[key];
      if(Ember.isPresent(msg)) { this.displayMessage('error', msg); }
    });
  },

  /**
    Remove flash message.

    @method removeMessage
    @param {Object} message to be removed
  */

  removeMessage(message) {
    this.get('messages').removeObject(message);
  },

  /**
    Remove all flash messages in the application.
    Automatically called during route transitions and overlay close.
    ```
    this.flash.clearAllMessages();
    ```

    @method clearAllMessages
  */

  clearAllMessages() {
    this.set('messages', []);
  }
});
