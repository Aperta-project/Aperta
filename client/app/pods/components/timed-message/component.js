import Ember from 'ember';

/**
  ## How to Use

  In your template:

  ```
  {{timed-message message=reallyImportantMessage
                  class="custom-class-here"
                  duration=8000}}
  ```

  In your controller or component set the message:

  ```
  save: function() {
    this.get('model').save().then(() => {
      this.set('reallyImportantMessage', 'You did good');
    });
  }
  ```
*/

export default Ember.Component.extend({
  /**
    Length of time in miliseconds before message is removed

    @property duration
    @type number
    @default 5000
  */

  duration: 5000,

  /**
    Text displayed to user

    @property message
    @type String
    @default ''
  */

  message: '',

  messageDidChange: Ember.observer('message', function() {
    this.$().html(this.get('message'));

    Ember.run.later(this, function() {
      this.set('message', '');
    }, this.get('duration'));
  })
});
