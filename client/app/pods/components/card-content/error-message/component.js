import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    scenario: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool.isRequired
  }
});
