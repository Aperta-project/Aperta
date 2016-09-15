import FactoryGuy from 'ember-data-factory-guy';


FactoryGuy.define('adhoc-attachment', {
  default: {
    alt: 'adhoc_attachment alternate text',
    caption: 'adhoc_attachment caption',
    detailSrc: 'adhoc_attachment_detail.jpg',
    filename: 'adhoc_attachment.jpg',
    previewSrc: 'adhoc_attachment_preview.jpg',
    src: 'adhoc_attachment.jpg',
    status: 'done',
    title: 'adhoc_attachment Title'
  }
});
