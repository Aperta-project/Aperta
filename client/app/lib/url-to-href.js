export default function(text, newWindow=false) {
  let string     = text;
  let linkRegExp = /((?:https?:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.])(?:[^\s()<>]+|\([^\s()<>]+\))+(?:\([^\s()<>]+\)|[^`!()\[\]{};:'".,<>?«»“”‘’\s]))/gmi;
  let wwwRegExp  = /^www\d{0,3}[.]/i;

  let startsWithWWW = function(string) {
    return wwwRegExp.test(string);
  };

  let target = newWindow ? ' target="_blank"' : '';

  let toHref = function(match) {
    let href = match;
    if(startsWithWWW(match)) { href = 'http://' + match; }

    return `<a href="${href}"${target}>${match}</a>`;
  };

  return string.replace(linkRegExp, toHref);
}
