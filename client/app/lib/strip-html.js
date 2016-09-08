export default function(string) {
  if(string) {
    // Div wrapper: If no html is present the text function
    // will return an empty string
    return $('<div>' + string + '</div>').text();
  }

  return '';
}
