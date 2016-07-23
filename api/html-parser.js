'use strict';

var cheerio = require('cheerio');
var _ = require('underscore');

const DEFAULT_PROTOCOL = 'https';

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
    protocol = protocol || DEFAULT_PROTOCOL;
    return `${protocol}:${str}`;
  }
}

module.exports = _.extend(HtmlParser, {
  DEFAULT_PROTOCOL: DEFAULT_PROTOCOL
});