'use strict';

var cheerio = require('cheerio');

const defaultProtocol = 'https';

class HtmlParser {
  static attrFromSelector(html, selector, attribute) {
    let $ = cheerio.load(html);
    let res = [];
    $(selector).each((i, el) => {
      res.push($(el).attr(attribute));
    });
    return res;
  }

  static addProtocol(str, protocol) {
    protocol = protocol || defaultProtocol;
    return `${protocol}:${str}`;
  }
}

module.exports = HtmlParser;