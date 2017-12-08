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
      label: 'Label',
      text: 'A short input question'
    },
    description: {
      contentType: 'description',
      valueType: null,
      text: 'Here is a paragraph of unanswerable text'
    },
    checkBox: {
      contentType: 'check-box',
      valueType: 'boolean',
      defaultAnswerValue: 'false',
      text: 'Check box default text'
    },
    list: {
      contentType: 'bulleted-list',
      valueType: null
    }
  }
});
