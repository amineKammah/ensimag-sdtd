from pymongo import MongoClient

client = MongoClient('mongodb://mongodb-0.database:27017')

db = client.database

db.images.insert({
    'image':'test_data/how_to_win_arguments/0001.jpg',
    'text':'How to win every argument the use and abuse of logic madsen pirie',
})