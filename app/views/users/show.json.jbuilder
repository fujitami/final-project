json.album do
  json.array! @current_user_album_ids_hash  do |key, value|
    json.spotifyAlbumId key
    json.tagId value
  end
end

json.current_user_color @current_user_tag_id_color
