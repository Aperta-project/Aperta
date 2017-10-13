import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card-content', {
  default: {
    contentType: 'short-input',
    valueType: 'text',
    text: 'Default cardContent test text',
    ident: '',
  },

  traits: {
    shortInput: {
      contentType: 'short-input',
      valueType: 'text',
      text: 'A short input question'
    },
    description: {
      contentType: 'description',
      valueType: null,
      text: 'Here is a paragraph of unanswerable text'
    },
    list: {
      contentType: 'bulleted-list',
      valueType: null
    }
  }
});
