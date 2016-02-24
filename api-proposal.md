`TODO` `login/auth`
___

`TODO` `facebookFriends`
___

`GET` `userId/invitations`

```js
response: {
  invites: Array of {
    id: String,
    name: String,
    friends: Array of {
      todo: todo
    }
  }
}
```
___

`POST` `userId/event`

```js
params: {
  title: String,
  location: {
    type: String ("address" || "cll")
    val: String (address) || { lat: Number, long: Number }
  },
  friends: Array of {
    todo: todo
  },
  search: (optional) String,
  price: (optional) Number (one of [0, 1, 2, 3] where 2 corresponds to "$$$" or cheaper) defaults to 3,
  open: (optional) Boolean  defaults to false,
  placesNumber: (optional) Number (of resturants to return) defaults to todo
}
```

```js
response: {
  results: Array of {
    yelpId: String,
    name: String,
    rating: Number ([1, 1.5, ... 5]),
    price: Number (one of [0, 1, 2, 3] where 2 corresponds to "$$$"),
    link: todo (either web URL, mobile URL, deeplink, or all of the above),
    images: todo (probably Array of X image URLs),
    reservationUrl: String (URL to SeatMe),
    deliveryUrl: String (URL to Eat24)
  }
}
```
___
  
`POST` `eventId/results`

```js
params: {
  results: {
    userId: {
      all: Array of (for each image on each page) {
        imageUrl: String,
        yelpId: String (of restaurant),
        selected: Boolean
      },
      selected: Array of (for each selected image on each page) {
        imageUrl: String,
        yelpId: String (of restaurant)
      },
      numberOfPhotosPerPage: Number
    },
    userId...
  }
}
```

```js
response: {
  restuarant: {
    yelpId: String,
    name: String,
    rating: Number ([1, 1.5, ... 5]),
    price: Number (one of [0, 1, 2, 3] where 2 corresponds to "$$$")
    link: todo (either web URL, mobile URL, deeplink, or all of the above)
    images: todo (probably Array of X image URLs)
    reservationUrl: String (URL to SeatMe),
    deliveryUrl: String (URL to Eat24)
  },
  todo: chosen because XYZ (probably images)
}
```
___
