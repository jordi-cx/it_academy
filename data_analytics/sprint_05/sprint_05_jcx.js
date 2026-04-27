/* 
Sprint 5 - MongoDB
IT Academy - Data Analytics
Jordi Calmet Xartó

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_05
*/


// Nivell 1. Exercici 1

// Mostra els 2 primers comentaris que hi ha en la base de dades.

// Project:
{ name: 1, text: 1, date: 1, _id: 0 }
// Sort:   
{ date: 1 }
// Limit:  2

/*
{
"name": "Mercedes Tyler",
"text": "Optio totam dolores magni. Enim ratione fuga tempora voluptatum est cumque animi. Quia nam doloribus corrupti id voluptate esse. Tempore maiores omnis aliquam ad quisquam quidem.",
"date": "1970-01-01T01:07:09.000Z"
}

{
"name": "Jon Snow",
"text": "Dolorem animi tempora ullam quas. Iusto nobis reprehenderit aspernatur cupiditate a tempore. Commodi alias expedita dolore explicabo ipsam.",
"date": 1970-01-01T09:37:49.000Z"
}
*/

// Código completo:
// db.comments.find({}).sort({ date: 1 }).limit(5)


// Quants usuaris tenim registrats?

// Filter: 
{ email: { $ne: null } }
// 185 users

// db.users.countDocuments({ email: { $ne: null } })
// db.users.distinct("email").length


// Quants cinemes hi ha en l'estat de Califòrnia?
{ "location.address.state": "CA" }
// 169 theaters

// { "location.address.state": { $in: ["CA", "California"] }}
// db.theaters.countDocuments({ "location.address.state": { "$in": ["CA", "California"] } })
/*
{
  "$or": [
    { "location.address.state": "CA" },
    { "location.address.state": "California" }
  ]
}
*/


// Quin va ser el primer usuari/ària en registrar-se?

// Sort: 
{ _id: 1 }
// db.users.find({}).sort({ _id: 1 }).limit(1)
// _id: "59b99db4cfa9a34dcd7885b6"
 

// Quantes pel·lícules de comèdia hi ha en la nostra base de dades?
{ genres: "Comedy" }
// db.movies.countDocuments({ genres: "Comedy" })
// 7024 movies


// Nivell 1. Exercici 2
// Movies from 1932 but with either Drama genre or French language
{
  year: 1932,
  $or: [
    { genres: "Drama" },
    { languages: "French" }
  ]
}


// Nivell 1. Exercici 2
// Movies from USA having between 5 to 9 awards and being produced between 2012 and 2014

{
	"countries": "USA",
	"awards.wins": { "$gte": 5, "$lte": 9 },
	"year": { "$gte": 2012, "$lte": 2014 }
}

/*
db.movies.countDocuments({
  "countries": "USA",
  "awards.wins": { "$gte": 5, "$lte": 9 },
  "year": { "$gte": 2012, "$lte": 2014 }
})
*/

// Nivell 2. Exercici 1
// Comments from '@gameofthron.es'

{ "email": /@gameofthron\.es/i }
{ "email": { "$regex": "@gameofthron\\.es", "$options": "i" } }


// Nivell 2. Exercici 2
// Cinemas in every postal code from the state Washington DC (DC)

// Aggregation -> Add Stage: $match
{ "location.address.state": "DC" }

// Aggregation -> Add Stage: $group
{
  "_id": "$location.address.zipcode",
  "total_theaters": { "$sum": 1 }
}

/*
db.theaters.aggregate([
  // Stage 1: Filter to only include DC
  {
    $match: { "location.address.state": "DC" }
  },
  // Stage 2: Group by zip code and count
  {
    $group: {
      _id: "$location.address.zipcode",
      total_theaters: { $sum: 1 }
    }
  }
])
*/


// Nivell 3. Exercici 1
// Movies by John Landis with IMDB rating between 7.5 - 8

// Filter:
{
	"directors": "John Landis",
	"imdb.rating": { "$gte": 7.5, "$lte": 8.0 }
}

// Project:
{ "title": 1, "_id": 0 }

// 4 movies:
// 'Animal House'
// 'The Blues Brothers'
// 'An American Werewolf in London'
// 'Trading Places'

/*
db.movies.find(
  { 
    "directors": "John Landis", 
    "imdb.rating": { "$gte": 7.5, "$lte": 8.0 } 
  }, 
  { 
    "title": 1, 
    "_id": 0 
  }
)
*/


// Nivell 3. Exercici 2
// In Compass: Schema -> Analyze Schema -> Map

//

