export default function(type) {

  if ( /\.(jpe?g|png|gif|bmp)$/i.test(type) ) {
    return 'Image';
  }

  if ( /\.(doc|docx)$/i.test(type) ) {
    return 'Word';
  }

  if ( /\.(xls|xlsx)$/i.test(type) ) {
    return 'Excel';
  }

  if ( /\.(ppt|pptx)$/i.test(type) ) {
    return 'Powerpoint';
  }

  if ( /\.(pdf)$/i.test(type) ) {
    return 'PDF';
  }

  if ( /\.(mp4|mpg)$/i.test(type) ) {
    return 'Movie';
  }

  if ( /\.(mp3|flac|wav)$/i.test(type) ) {
    return 'Audio';
  }

  if ( /\.(zip|tar)$/i.test(type) ) {
    return 'Zip';
  }

  if ( /\.(rb|java|py)$/i.test(type) ) {
    return 'Code';
  }

  if ( /\.(txt)$/i.test(type) ) {
    return 'Text';
  }
}
