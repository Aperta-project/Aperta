import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [
    ':task-disclosure',
    '_taskVisible:task-disclosure--open'
  ],

  /**
   *  Should task component be rendered?
   *
   *  @property _taskVisible
   *  @type Boolean
   *  @default false
   *  @private
  **/
  _taskVisible: false,

  /**
   *  Text to be displayed in heading
   *
   *  @property title
   *  @type String
   *  @default ''
   *  @required
  **/
  title: '',

  /**
   *  Is the task completed?
   *
   *  @property completed
   *  @type Boolean
   *  @default false
   *  @required
  **/
  completed: false,

  actions: {
    toggleVisibility() {
      this.toggleProperty('_taskVisible');
    }
  }
});
