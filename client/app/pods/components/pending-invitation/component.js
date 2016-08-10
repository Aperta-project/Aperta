import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    user: PropTypes.object.isRequired,
    invitation: PropTypes.object.isRequired
  },
  classNames: ['invite-editor-edit-invite']
});
