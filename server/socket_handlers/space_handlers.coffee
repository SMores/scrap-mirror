db = require '../../models'

module.exports =
  
  # create a new space and save it to the db
  newSpace : (sio, socket, data, callback) ->
    name = data.name
    spaceId = data.spaceId
    db.Space.create( { name } ).complete (err, space) ->
      return callback err if err?
      socket.emit 'newSpace', { space }
      callback()
    

  # reorder the columns in a space
  reorderSpace : (sio, socket, data, callback) ->
    spaceId = data.spaceId
    columnSorting = data.columnSorting

    # first find the space
    db.Space.find(where: { id: spaceId } ).complete (err, space) ->
      return callback err if err?
      # update the columns
      space.updateAttributes( { columnSorting } ).complete (err) ->
        return callback err if err?
        sio.to("#{spaceId}").emit 'reoderSpace', { columnSorting }
        callback()