### Users/Auth
todo

### Events

An event is a fig. It is created by a single user who is able to invite others. Events generate places that users decide between. Users perform actions on an event, resulting in a solution.

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
    "radius": (Number, optional) Radius of requested places in miles. Defaults to 1
  },
  "users": (Array) ids (String) of users invited to event. The id of the event creator should come first in the array,
  "search" (String, optional) Additional search terms e.g. sushi, brunch,
  "price": (Number, optional) One of [0, 1, 2, 3] where 2 corresponds to $$$ or cheaper. Note the difference between price representation on <Event Object>s and <Place Object>s. Defaults to 3,
  "isOpen": (Boolean, optional) "Open Now" status. Defaults to false,
  "isOver": (Boolean, optional) Whether the event has happened. Defaults to false,
  "limit": (Number, optional) Number of places considered for the solution to this event. Defaults to 5
}
```

###### Endpoints
```js
GET /users/:userId/invitations

response: (Array) <Event Object>s
```

```js
GET /events/:eventId

response: <Event Object>
```

```js
POST /events

request: <Event Object>

response: <Event Object>
```
___

### Places

A place is a restaurant. Several (default 5) places belong to a single event.

###### Representation
```js
{
  "id": (String) Id of place,
  "yelpId": (String) Yelp id of place,
  "event": (String) Id of event that generated this place,
  "name": (String) Name of place,
  "rating": (Number) Yelp rating. One of [1, 1.5, ... 5],
  "price": (Number) One of [0, 1, 2, 3] where 2 corresponds to exactly $$$,
  "links": {
    "reservation": (String) Reservation URL (SeatMe),
    "delivery": (String) Delivery URL (Eat24),
    "web": (String) Yelp web URL,
    "mobile": (String) Yelp mobile URL,
  },
  "images": (Array) Image links (String)     
}
```

###### Endpoints
```js
GET /events/:eventId/places

response: (Array) <Place Object>s
```

```js
GET /events/:eventId/solution

response: <Place Object>
```
___

### Actions

Actions are performed on events. Each user performs a single action on an event, encompassing all their selection decisions. Thus, an event with 3 users involved will have 3 actions - one for each user.

###### Representation

```js
{
  "id": (String) Id of action,
  "user": (String) Id of user performing action,
  "event": (String) Id of event that action belongs to,        
  "selections": (Array) Selection info. The array should include an image item (see below) for every image shown to the user
}

imageItem: {
  "image": (String) Image URL,
  "yelpId": (String) Yelp id of place that image belongs to,
  "isSelected": (Boolean) Whether user selected image
}
```

###### Endpoints

```js
POST /events/:eventId/actions

request: (Array) <Action Object>s

response: (Array) <Action Object>s
```
___

### Notes
* For simplcity, one representation is used for both `GET` and `POST` requests. However, you can omit `id` when creating a new resource (since it won't exist yet). The response to the creation will be the same resource, with the newly created `id` included.
* Likewise, an optional parameter may be omitted when creating resources. They will always be returned when reading a resource, with a value of `null` if it doesn't exist (and has no default value).
* Actions should be submitted only once for an event. Once submitted, the event will be marked as completed.
* If a user quits an event midway (or never starts), an action should not be submitted for the user. I.e. they should not affect the solution to the event.
