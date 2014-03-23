#Toodoo [![Build Status](https://travis-ci.org/timhabermaas/toodoo.svg?branch=travis-ci)](https://travis-ci.org/timhabermaas/toodoo)

*Toodoo* is a simple application which demonstrates the [hexagonal architecture](http://alistair.cockburn.us/Hexagonal+architecture) in Ruby. This architecture decouples the application from several implementation details like the database or the delivery mechanism (e.g. the web) and makes unit testing the business logic easy and enjoyable.

##Credits

The code is heavily influenced by Robert C. Martin's [Architecture the Lost Years](https://www.youtube.com/watch?v=WpkDN78P884) talk and a series of blog post from Adam Hawkins titled [Rediscovering the Joy of Desing](http://hawkins.io/2014/01/rediscovering-the-joy-of-design/). Thanks to both of them for their great work!

##Domain

The domain is a simple multi-user Todo application. So far you can create todos and mark them as completed.

##The relevant parts

###Use Cases

Every use case of the application is represented by one class. These classes have access to the database and encapsulate all the business logic in the method `call`. The parameters provided for these classes are primitive data structures which make providing dummy data in tests pretty easy.

####Issues

The authorization rules and the use case currently live together in one class. This breaks the single responsibility principle and might lead to deeply nested tests once the business rules and authorization rules get more complex. Solution: Extract the authorization rules into policy classes (e.g. `CreateTodoPolicy`) and avoid a lot of boiler plate code by using Ruby's meta programming features.

###Entities

*Entities* are a mixture of [data transfer objects (DTO)](http://en.wikipedia.org/wiki/Data_transfer_object) and [business models](http://martinfowler.com/eaaCatalog/domainModel.html) which support the *use cases* and help communicating the domain model.

###Forms

Form (or request) objects live on the boundary between the outside world and the use cases. They provide ways to validate input and make use cases only operate on valid data. They can also support forms in web applications.

####Issues

I'm basically creating an [anemic domain model](http://www.martinfowler.com/bliki/AnemicDomainModel.html) since the entites have almost no business logic\*. I'm not sure that's as bad as Martin Fowler makes it sound like. The future will tell.

\* I try to avoid breaking encapsulation by adding methods which operate on the data of the entity. For example I call `task#done` from the `MarkTodoAsDone` instead of `task.done = false`. Another way to see the Entity-UseCase relationship is to think of the entities as the functional core and the use cases as the imperative shell.

###Gateways

*Gateways* provide a way to access the outside world from the use cases. They are passed in to the use cases through the constructors and are therefore easily replaced in the tests.

Currently there only exist gateways for database access, but gateways for sending emails or accessing 3rd-party APIs are conceivable as well.

####Repositories

The two database gateways `InMemoryDatabase` and `RedisDatabase` serve as repositories with domain-specific persistence methods. Providing this abstraction layer makes it a) easy to swap out the database in tests and production and b) easy to see the requirements the application has on the persistence layer. Therefore the decision what database to use can be deferred to much later and is made easier by the clearly provided requirements.

##More Resources

* https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell
* https://www.destroyallsoftware.com/talks/boundaries
