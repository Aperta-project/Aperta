import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('figure', {
  default: {
    alt: 'figure alternate text',
    caption: 'figure caption',
    detailSrc: 'figure_detail.jpg',
    filename: 'figure_filename.jpg',
    previewSrc: 'figure_preview.jpg',
    src: 'figure.jpg',
    status: 'done',
    title: 'Figure Title',
    strikingImage: false,
    rank: 0
  }
});
