export default function (string) {
  // This function is intended to make HTML markup into a line. It plans
  // to achieve this by doing two things.
  //
  // 1. Replace carriage-returns with spaces
  // 2. Replace HTML tags with a space
  return string.replace(/<\/?[^>]+(>|$)/g, ' ').replace(/[\n\r]/g, '');
}
