import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [
    ':task-disclosure',
    '_taskVisible:task-disclosure--open',
    'typeIdentifier'
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
   *  The type of the task
   *
   *  @property type
   *  @type String
   *  @default ''
   *  @required
   **/
  type: '',

  /**
   *  Is the task completed?
   *
   *  @property completed
   *  @type Boolean
   *  @default false
   *  @required
  **/
  completed: false,

  typeIdentifier: Ember.computed('type', function() {
    const dasherizedType = Ember.String.dasherize(this.get('type'));
    return `task-type-${dasherizedType}`;
  }),

  actions: {
    toggleVisibility() {
      this.toggleProperty('_taskVisible');
    }
  }
});
