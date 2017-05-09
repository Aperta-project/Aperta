import DS from 'ember-data';
import { isPresent } from 'tahi/lib/computed';

export default DS.Model.extend({
  card: DS.belongsTo('card'),
  contentRoot: DS.belongsTo('card-content', { async: false }),
  publishedAt: DS.attr('date'),
  historyEntry: DS.attr('string'),
  publishedBy: DS.attr('string'),

  isPublished: isPresent('publishedAt')
});
