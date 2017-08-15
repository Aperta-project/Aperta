import FactoryGuy from 'ember-data-factory-guy';


FactoryGuy.define('manuscript-attachment', {
  default: {
    alt: 'manuscript_attachment alternate text',
    caption: 'manuscript_attachment caption',
    detailSrc: 'manuscript_attachment_detail.jpg',
    filename: 'manuscript_attachment.jpg',
    previewSrc: 'manuscript_attachment_preview.jpg',
    src: 'manuscript_attachment.jpg',
    status: 'done',
    title: 'manuscript_attachment Title'
  }
});
