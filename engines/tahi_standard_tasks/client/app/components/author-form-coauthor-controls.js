import Ember from 'ember';
import PropTypeMixin, {PropTypes} from 'ember-prop-types'

const {
  Component
} = Ember;

export default Component.extend(PropTypes, {
  
  author: PropTypes.EmberObject,
  disabled: PropTypes.bool,
  controlsVisible: PropTypes.bool,

  modifiedBy: Ember.computed('author.coAuthorStateModifiedBy.fullName', function(){
    let modifiedBy = this.get('author.coAuthorStateModifiedBy.fullName');
    if (modifiedBy) {
      return modifiedBy;
    } else {
      return 'email';
    }
  }),

  humanizedCoAuthorState: Ember.computed('author.coAuthorState', function(){
    switch(this.get('author.coAuthorState')) {
    case 'confirmed':
      return 'Confirmed by';
    case 'refuted':
      return 'Refuted By';
    default:
      return 'Last changed by';
    }
  }),

  actions: {
    setConfirmation(status) {
      this.attrs.setConfirmation(status);
    }
  }

  
})
