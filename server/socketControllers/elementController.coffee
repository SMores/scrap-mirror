db = require '../../models'
async = require 'async'
module.exports =

  # create a new element and save it to db
  newElement : (sio, socket, data, spaceKey, callback) =>

    db.Space.find(where: { spaceKey }).complete (err, space) =>
      return callback err if err?
      
      options =
        contentType : data.contentType
        content : data.content
        caption : data.caption
        x: data.x
        y: data.y
        z: data.z
        scale: data.scale
        SpaceId: space.id

      db.Element.create(options).complete (err, element) =>
        return callback err if err?
        sio.to("#{spaceKey}").emit 'newElement', { element }
        callback()

  # delete the element
  removeElement : (sio, socket, data, spaceKey, callback) =>
    id = data.elementId
    # find/delete the element
    db.Element.find(where: { id } ).complete (err, element) =>
      return callback err if err?
      return callback() if not element? 
      element.destroy().complete (err) =>
        return callback err if err?
        sio.to("#{spaceKey}").emit 'removeElement', { element }
        callback()

  # moves an element from one column to another
  updateElement : (sio, socket, data, spaceKey, callback) =>
    data.id = +data.elementId

    query = "UPDATE \"Elements\" SET"
    query += " \"x\"=:x," if data.x?
    query += " \"y\"=:y," if data.y?
    query += " \"z\"=:z," if data.z?
    query += " \"scale\"=:scale" if data.scale?
    # remove the trailing comma if necessary
    query = query.slice(0,query.length - 1) if query[query.length - 1] is ","
    query += " WHERE \"id\"=:id RETURNING *"

    # new element to be filled in by update
    element = db.Element.build()

    db.sequelize.query(query, element, null, data).complete (err, result) ->
      return callback err if err?
      sio.to("#{spaceKey}").emit 'updateElement', { element: result }
      callback()
