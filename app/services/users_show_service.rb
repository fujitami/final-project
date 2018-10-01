class UsersShowService
def initialize(user)
  @current_user = user
end

  def get_album_ids
    # ログイン中ユーザがタグ付けしたアルバム(最新順)
    album_current_user = Album.includes(:taggings).where('taggings.tagger_id = ?', @current_user.id).references(:taggings).group(:spotify_id).order('albums.id desc')
    album_spotify_id = album_current_user.pluck(:spotify_id)
    album_tag_id =  album_current_user.pluck(:tag_id) #ログイン中ユーザが選択したタグ
    album_ids =[album_spotify_id, album_tag_id].transpose
    album_ids_hash = Hash[*album_ids.flatten] #{album_spotify_id: album_tag_id}という形のハッシュを作成
  end
end
