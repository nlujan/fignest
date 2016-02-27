### Events

An event is a fig. It is created by a single user who is able to invite others. Users perform actions on an event, resulting in solution.
###### Representation
```js
{
  "id": (String) Id of event,
  "name": (String) Name of event,
  "location": {
    "type": (String) Type of location data. Either "address" or "coord",
    "address": (String) Address of locaton, if type is "address",
    "lat": (Number) Latitide of location, if type is "coord",
    "long": (Number) Longitude of location, if type is "coord",
    "radius": (Number, optional) Radius of requested places in miles. Defaults to todo
  },
  "users": (Array) ids (String) of users invited to event. The id of the event creator should come first in the array,
  "search" (String, optional) Additional search terms e.g. sushi, brunch,
  "price": (Number, optional) One of [0, 1, 2, 3] where 2 corresponds to $$$ or cheaper. Note the difference between price representation on Event Objects and Place Objects. Defaults to 3,
  "isOpen": (Boolean, optional) "Open Now" status. Defaults to false,
  "isOver": (Boolean, optional) Whether the event has happened. Defaults to false,
  "limit": (Number, optional) Number of places considered for the solution to this event. Defaults to 5
}
```

###### Endpoints
```js
GET /users/:userId/invitations

response: (Array) Event Objects
```

```js
POST /events

request: Event Object

response: Event Object
```

###### See
[`Event`]()
___

### Places

Places blah. places belong to an event. place is restaurant

###### Representation
```js
{
  "id": (String) Id of place,
  "yelpId": (String) Yelp id of place,
  "event": (String) Id of event that generated this place,
  "name": (String) Name of place,
  "rating": (Number) Yelp rating. One of [1, 1.5, ... 5],
  "price": (Nu,ber) One od [0, 1, 2, 3] where 2 corresponds to exactly $$$,
  "links": {
  }
}
```

```js
GET /events/:eventId/places

response:
[Place Object, ...]
```
See: [`Place`]()
___

```js
POST /events/:eventId/actions

request:
[Action Object, ...]

response:
[Action Object, ...]
```
See: [`Action`]()
___

```js
GET /events/:eventId/solution

response:
Place Object
```
See: [`Place`]()
___
