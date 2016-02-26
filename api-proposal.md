`GET` `/users/:userId/invitations`

* `response`:

| Name | Description                  | Type         |
|------|------------------------------|--------------|
|      | **Array** of user's invitations | `Event` |
___

`POST` `/events`

* `params`:

| Name        | Description                                                                                    | Type      |
|-------------|------------------------------------------------------------------------------------------------|-----------|
| `title`     | Title of event                                                                                 | `String`  |
| `location`  | Desired location                                                                               | `Object`  |
| __`type`    | Type of location data. Either `"address"` or `"coord"`.                                        | `String`  |
| __`address` | Address of location, if  `type` is `"address"`                                                 | `String`  |
| __`lat`     | Latitude of location, if `type` is `"coord"`                                                   | `Number`  |
| __`long`    | Longitude of location, if `type` is `"coord"`                                                  | `Number`  |
| __`radius`  | *optional* Radius of requested places in miles. Defaults to todo.                              | `Number`  |
| `friends`   | **Array** of friends to invite                                                                     | todo      |
| `creator`   | `id` of creator                                                                                | `String`  |
| `search`    | *optional* Additional search terms e.g. sushi, brunch                                          | `String`  |
| `price`     | *optional* One of `[0, 1, 2, 3]` where `2` corresponds to `"$$$"` or cheaper. Defaults to `3`. | `Number`  |
| `open`      | *optional* Whether the solution needs to be open now. Defaults to `false`.                     | `Boolean` |
| `limit`     | *optional* Number of places to consider for the solution to this event. Defaults to `5`.       | `Number`  |

* `response`:

| Name | Description         | Type    |
|------|---------------------|---------|
|      | Newly created event | `Event` |
___

`GET` `/events/:eventId/places`

* `response`:

| Name | Description         | Type    |
|------|---------------------|---------|
|      | **Array** of places for event | `Place` todo |
___

`POST` `/events/:eventId/actions`

* `params`:

| Name | Description         | Type    |
|------|---------------------|---------|
|      | **Array** of user actions | `Action` todo |

* `response`:

| Name | Description         | Type    |
|------|---------------------|---------|
|      | **Array** of user actions | `Action` todo |
___

`GET` `/events/:eventId/solution`

* `response`:

| Name | Description         | Type    |
|------|---------------------|---------|
|      | Solution for event based on actions | `Place` todo |
___

`Event`

| Name        | Description                                                                                    | Type      |
|-------------|------------------------------------------------------------------------------------------------|-----------|
| `id`        | `id` of event                                                                                  | `String`  |
| `title`     | Title of event                                                                                 | `String`  |
| `location`  | Location input for event creation                                                              | `Object`  |
| __`type`    | Type of location data. Either `"address"` or `"coord"`.                                        | `String`  |
| __`address` | Address of location, if  `type` is `"address"`                                                 | `String`  |
| __`lat`     | Latitude of location, if `type` is `"coord"`                                                   | `Number`  |
| __`long`    | Longitude of location, if `type` is `"coord"`                                                  | `Number`  |
| __`radius`  | *optional* Radius of requested places in miles. Defaults to todo.                              | `Number`  |
| `friends`   | **Array** of invited friends                                                                       | `Person`  |
| `creatorId`   | `id` of creator                                                                                | `String`  |
| `search`    | *optional* Additional search terms e.g. sushi, brunch                                          | `String`  |
| `price`     | *optional* One of `[0, 1, 2, 3]` where `2` corresponds to `"$$$"` *or cheaper* (note the difference in the price value between an `Event` and a `Place`. Defaults to `3`. | `Number`  |
| `isOpen`      | *optional* "Open now" status. Defaults to `false`.                                             | `Boolean` |
| `isOver`      | *optional* Whether the event has happened. Defaults to `false`.                                             | `Boolean` |
| `limit`     | *optional* Number of places considered for the solution to this event. Defaults to `5`.        | `Number`  |
___

Note that you can omit `id` for request params when creating a resource. I.e omit in param but not in url
optional refers to value when inputing param. WIll always be returned from API. If an optional value does not have a default, it will be `null`
explain underscores

`Person`
todo may be able to sub just id

`Place`
todo

| Name            | Description                                                      | Type     |
|-----------------|------------------------------------------------------------------|----------|
| `id`            | `id` of place                                                    | `String` |
| `yelpId`        | Yelp `id` of place                                               | `String` |
| `eventId`       | `id` of event that generated this place, if such an event exists | `String` |
| `name`          | Name                                                             | `String` |
| `rating`        | One of `[1, 1.5, ... 5]`                                         | `Number` |
| `price`         | One of `[0, 1, 2, 3]` where `2` corresponds to `"$$$"`           | `Number` |
| `links`         | todo (either web URL, mobile URL, deeplink, or all of the above) | `Object` |
| __`reservation` | Reservation URL to SeatMe                                        | `String` |
| __`delivery`    | Delivery URL to Eat24                                            | `String` |
| __`web`         | Web URL                                                          | `String` |
| __`mobile`      | Mobile URL                                                       | `String` |
| `images`        | **Array** of image links (probably, todo, todo amount)               | `String` |


`Action`

An action is for a specific user across the whole event

| Name           | Description                                                                                   | Type     |
|----------------|-----------------------------------------------------------------------------------------------|----------|
| `userId`       | `id` of user performing action                                                                | `String` |
| `selections`   | **Array** of selection information. Should include an item for every image shown to the user. | `Object` |
| __`image`      | Image URL                                                                                     | `String` |
| __`yelpId`     | Yelp `id` of place that image belongs to                                                      | `String` |
| __`isSelected` |                                                                                               |          |
|                |                                                                                               |          |
|                |                                                                                               |          |
|                |                                                                                               |          |
|                |                                                                                               |          |
