import FactoryGuy from 'ember-data-factory-guy';


FactoryGuy.define('decision-attachment', {
  default: {
    file: { url: 'http://example.com/1' },
    status: 'done',
    title: 'decision_attachment Title'
  }
});
