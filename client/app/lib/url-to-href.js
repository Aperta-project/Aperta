export default function(text, newWindow=false) {
  const string     = (text || "");
  const linkRegExp = /((?:https?:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.])(?:[^\s()<>]+|\([^\s()<>]+\))+(?:\([^\s()<>]+\)|[^`!()\[\]{};:'".,<>?«»“”‘’\s]))/gmi;
  const wwwRegExp  = /^www\d{0,3}[.]/i;

  const startsWithWWW = function(string) {
    return wwwRegExp.test(string);
  };

  const target = newWindow ? ' target="_blank"' : '';

  const toHref = function(match) {
    let href = match;
    if(startsWithWWW(match)) { href = 'http://' + match; }

    return `<a href="${href}"${target}>${match}</a>`;
  };

  return string.replace(linkRegExp, toHref);
}
