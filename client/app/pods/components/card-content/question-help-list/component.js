import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['question-help', 'card-content-question-help-list'],
  tagName: 'ol',

  liClass: Ember.computed('content.parent', function() {
    if (this.get('content.parent.contentType') === 'display-children') {
      return 'left-indent';
    } else {
      return 'item';
    }
  })
});
