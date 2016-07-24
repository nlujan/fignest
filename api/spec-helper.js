'use strict';

class SpecHelper {
  constructor() {

  }

  getUser() {
    return {
      facebook: {
        id: `${Math.random()}`,
        email: 'uniq0@gmail.com',
        name: 'User0'
      }
    };
  }

  getEvent() {
    return {
      name: 'Sample Event 0',
      location: {
        type: 'address',
        address: 'East Village NYC'
      },
      search: 'bbq',
      isOver: false
    };
  }
}

module.exports = SpecHelper;