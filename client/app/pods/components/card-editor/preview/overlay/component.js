import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-editor-preview-overlay'],
  renderAsDualColumn: Ember.computed.alias('card.content.renderAsDualColumn')
});
