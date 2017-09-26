import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-repeat'],
  tagName: '',

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  addLabelText: Ember.computed('content', function() {
    let label = this.get('content.addButtonLabel');
    return label ? label : 'Add';
  })
});
