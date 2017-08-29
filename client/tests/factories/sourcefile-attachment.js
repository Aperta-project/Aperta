import FactoryGuy from 'ember-data-factory-guy';


FactoryGuy.define('sourcefile-attachment', {
  default: {
    alt: 'sourcefile_attachment alternate text',
    caption: 'sourcefile_attachment caption',
    detailSrc: 'sourcefile_attachment_detail.jpg',
    filename: 'sourcefile_attachment.jpg',
    previewSrc: 'sourcefile_attachment_preview.jpg',
    src: 'sourcefile_attachment.jpg',
    status: 'done',
    title: 'sourcefile_attachment Title'
  }
});
