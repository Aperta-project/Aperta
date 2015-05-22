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
  active: function() {
    return this.get('value') === this.get('parentView.selectedValue');
  }.property('value', 'parentView.selectedValue'),

  click() {
    this.get('parentView').valueSelected(this.get('value'));
  }
});
