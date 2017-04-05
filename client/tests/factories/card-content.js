import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card-content', {
  default: {
    contentType: 'text',
    text: 'Answer my question',
    ident: '',
  },

  traits: {
    shortInput: {
      contentType: 'short-input',
      text: 'A short input question'
    }
  }
});



