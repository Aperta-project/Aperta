import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
  classNames: ['card-content'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
  },

  onclick() {},  // Default onclick action if none passed in

  hasLabel: Ember.computed.notEmpty('content.label'),
  hasText: Ember.computed.notEmpty('content.text'),
});
