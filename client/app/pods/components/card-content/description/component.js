import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
  classNames: ['card-content', 'card-content-view-text'],

  hasListParent: Ember.computed.equal('content.parent.childTag', 'li'),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
  }
});
