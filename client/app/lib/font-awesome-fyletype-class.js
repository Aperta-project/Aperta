export default function(type) {

  if ( /\.(jpe?g|png|gif|bmp)$/i.test(type) ) {
    return 'file-image-o';
  }

  if ( /\.(doc|docx)$/i.test(type) ) {
    return 'file-word-o';
  }

  if ( /\.(xls|xlsx)$/i.test(type) ) {
    return 'file-excel-o';
  }

  if ( /\.(ppt|pptx)$/i.test(type) ) {
    return 'file-powerpoint-o';
  }

  if ( /\.(pdf)$/i.test(type) ) {
    return 'file-pdf-o';
  }

  if ( /\.(mp4|mpg)$/i.test(type) ) {
    return 'file-movie-o';
  }

  if ( /\.(mp3|flac|wav)$/i.test(type) ) {
    return 'file-audio-o';
  }

  if ( /\.(zip|tar)$/i.test(type) ) {
    return 'file-archive-o';
  }

  if ( /\.(rb|java|py)$/i.test(type) ) {
    return 'file-code-o';
  }

  if ( /\.(txt)$/i.test(type) ) {
    return 'file-text-o';
  }

  if ( /\.(tex)$/i.test(type) ) {
    return 'file-text-o';
  }
}
