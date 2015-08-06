import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['edit-paper-button button-primary'],
  classNameBindings: ['buttonColor'],

  canEdit: false,
  isEditing: false,
  buttonColor: '',
  prompt: '',
  iconClass: '',

  buttonStates: {
    isEditing: {
      buttonColor: 'button--green',
      prompt: 'stop writing',
      iconClass: ''
    },
    canEdit: {
      buttonColor: 'button--green',
      prompt: 'start writing',
      iconClass: 'fa-pencil'
    },
    disabled: {
      buttonColor: 'button--disabled',
      prompt: 'start writing',
      iconClass: 'fa-pencil'
    }
  },

  buttonState: Ember.computed('canEdit', 'isEditing', function() {
    if (!this.get('canEdit'))  { return 'disabled';  }
    if (this.get('isEditing')) { return 'isEditing'; }
    return 'canEdit';
  }),

  click() {
    if (this.get('buttonState') !== 'disabled') {
      this.sendAction();
    }
  },

  buttonStateDidChange: function() {
    let state = this.get('buttonStates')[this.get('buttonState')];
    this.setProperties({
      buttonColor: state.buttonColor,
      prompt: state.prompt,
      iconClass: state.iconClass,
    });
  }.on('didInsertElement').observes('buttonState')
});
