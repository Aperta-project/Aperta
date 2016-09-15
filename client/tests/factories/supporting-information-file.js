import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('supporting-information-file', {
  default: {
    alt: 'SI file alt',
    filename: 'SI_file.doc',
    src: 'si-file-src',
    status: 'processing',
    title: 'Supporting Info Title',
    category: null,
    label: 'Supporting Info Label',
    caption: 'SI caption',
    publishable: true,
    strikingImage: false
  }
});
