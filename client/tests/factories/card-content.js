import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card-content', {
  default: {
    contentType: 'short-input',
    valueType: 'text',
    text: 'Answer my question',
    ident: '',
  },

  traits: {
    shortInput: {
      contentType: 'short-input',
      valueType: 'text',
      text: 'A short input question'
    },
    text: {
      contentType: 'text',
      valueType: null,
      text: 'Here is a paragraph of unanswerable text'
    }
  }
});



