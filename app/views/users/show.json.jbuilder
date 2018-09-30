json.array! @album_ids_hash  do |key, value|
  json.spotifyAlbumId key
  json.tagId value
end
