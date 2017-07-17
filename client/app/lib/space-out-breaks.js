export default function (string) {
  // This function is intended to change HTML breaks to spaces. It achieves this
  // by doing two things.
  //
  // 1. Replace HTML breaks with a space
  //    a. [edge-case] the break may have spaces before and after. This should
  //       only be replaced with one space.
  //
  // Regular Expression Clauses (in order)
  // 1. Replace HTML <br> tags with a single space.
  // 2. Similar to "trim"
  // 3. Similar to "squeeze" - one space separators - for non <pre>, <code> tags
  // 4. Remove line-breaks and carriage-returns
  //
  // Note, the "squeeze" replacement filter would squeeze out multiple spaces
  // within <pre> and <code> tags. This is not desirable, but is beyong the
  // scope of APERTA-10600 which this library was created for. Also, the
  // scenario this is used is when **a piece of HTML is to be displayed in one
  // line.**
  if (string) {
    return string.replace(/<br\/?(>|$)/g, ' ')
                 .replace(/^\s+|\s+$/g, '')
                 .replace(/\s+/g, ' ')
                 .replace(/(<[^\/|pre|code]+>)\s+/g, '$1')
                 .replace(/[\n\r]/g, '');
  }
  return '';
}
