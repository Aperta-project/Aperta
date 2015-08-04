import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['segmented-button'],
  classNameBindings: ['active:segmented-button--active'],

  /**
   * @property value
   * @type String
   * @default null
   * @required
   */
  value: null,

  /**
   * @property active
   * @type Boolean
   * @readOnly
   **/
  active: Ember.computed('value', 'parentView.selectedValue', function() {
    return this.get('value') === this.get('parentView.selectedValue');
  }),

  click() {
    this.get('parentView').valueSelected(this.get('value'));
  }
});
