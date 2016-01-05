export default function(type) {

  if ( /\.(jpe?g|png|gif|bmp)$/i.test(type) ) {
    return 'fa-file-image-o';
  }

  if ( /\.(doc|docx)$/i.test(type) ) {
    return 'fa-file-word-o';
  }

  if ( /\.(xls|xlsx)$/i.test(type) ) {
    return 'fa-file-excel-o';
  }

  if ( /\.(ppt|pptx)$/i.test(type) ) {
    return 'fa-file-powerpoint-o';
  }

  if ( /\.(pdf)$/i.test(type) ) {
    return 'fa-file-pdf-o';
  }

  if ( /\.(mp4|mpg)$/i.test(type) ) {
    return 'fa-file-movie-o';
  }

  if ( /\.(mp3|flac|wav)$/i.test(type) ) {
    return 'fa-file-audio-o';
  }

  if ( /\.(zip|tar)$/i.test(type) ) {
    return 'fa-file-archive-o';
  }

  if ( /\.(mp4|mpg)$/i.test(type) ) {
    return 'fa-file-movie-o';
  }

  if ( /\.(rb|java|py)$/i.test(type) ) {
    return 'fa-file-code-o';
  }

  if ( /\.(txt)$/i.test(type) ) {
    return 'fa-file-text-o';
  }
}
