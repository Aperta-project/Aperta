import Ember from 'ember';

/**
  ## How to Use

  In your template:

  ```
  {{#segmented-buttons selectedValue=sortBy action="setSortOrder"}}
    {{#segmented-button value="old"}}Sort by Oldest{{/segmented-button}}
    {{#segmented-button value="new"}}Sort by Newest{{/segmented-button}}
  {{/segmented-buttons}}
  ```

  In your component or route:

  ```
  actions: {
    setSortOrder(value) {
      this.set('sortBy', value);
    }
  }
  ```


  ## How it Works

  When a child `segmented-button` component is pressed, the `value` property of that component is
  sent up through the action defined on this `segmented-buttons` component.
  The `value` property of a clicked child segmented-button component is passed to the action set on the segmented-buttons component.
  A parent component or route is expected to catch this action and change the `selectedValue` property.
*/

export default Ember.Component.extend({
  classNames: ['segmented-buttons'],

  /**
   * @property selectedValue
   * @type Anything
   * @default null
   * @required
   */
  selectedValue: null,

  /**
    Method called by child `segmented-button` components

    @method valueSelected
    @param {String} value to be set to `selectedValue`
  */
  valueSelected(value) {
    this.sendAction('action', value);
  }
});
