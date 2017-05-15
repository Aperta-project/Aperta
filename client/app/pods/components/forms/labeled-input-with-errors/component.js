import Ember from 'ember';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    type: PropTypes.string,
    name: PropTypes.string,
    value: PropTypes.string,
    required: PropTypes.oneOfType([PropTypes.null, PropTypes.bool]),
    placeholder: PropTypes.string,
    helpText: PropTypes.string,
    label: PropTypes.string,
    errors: PropTypes.oneOfType([PropTypes.null, PropTypes.object]),
    enter: PropTypes.func,
    autofocus: PropTypes.bool
  },

  classNames: ['labeled-input-with-errors'],

  errorsPresentOnField: Ember.computed('errors', function(){
    return this.get('errors') &&
           this.get('errors').has(this.get('name'));
  }),

  errorMessageOnField: Ember.computed('errorsPresentOnField', function(){
    if(this.get('errorsPresentOnField')){
      const fieldName = this.get('name');
      const errorsOnField = this.get('errors').errorsFor(fieldName);
      return errorsOnField.mapBy('message').join(', ');
    }
  }),

  actions: {
    // Called when user hits enter while focused on the input
    enter() {
      const passedInEnterAction = this.get('enter');
      if (passedInEnterAction) passedInEnterAction();
    }
  }
});
