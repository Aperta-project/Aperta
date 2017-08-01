import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-editor-preview-overlay'],
  renderAdditionalText: Ember.computed('card.content', function() {
    return this.containsAdditionalText(this.get('card.content'));
  }),
  containsAdditionalText: function(cardContent) {
    if (!cardContent.get('unsortedChildren').length) {
      return cardContent.get('renderAdditionalText');
    } else {
      return cardContent.get('unsortedChildren').any((cc) => {
        return this.containsAdditionalText(cc);
      });
    }
  }
});
