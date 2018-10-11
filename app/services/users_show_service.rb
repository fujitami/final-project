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

  def get_tag_id_color
    current_user_tag_id_and_count = ActsAsTaggableOn::Tagging.where('tagger_id = ?', @current_user.id).group('tag_id').order('tag_id').count() #ユーザがこれまでにつけたタグとその回数を集計
    current_user_max_tag_id = current_user_tag_id_and_count.select {|k, v| v == current_user_tag_id_and_count.values.max }.keys #最も多くつけたタグのtag_idを取得

    # 最多タグが複数ある場合→より最近ついたタグの色を反映
    unless current_user_max_tag_id.length == 1
      latest_max_ids = current_user_max_tag_id.map { |tag_id| ActsAsTaggableOn::Tagging.where('tag_id = ?', tag_id ).maximum(:id) } #各タグの最新投稿時のidを配列に入れる
      latest_max_tag_id = current_user_max_tag_id[latest_max_ids.index(latest_max_ids.max)] #最も最近ついたタグがlatest_max_idsの何番目の要素か判定し、対応するcurrent_user_max_tag_idの要素を取り出す
      current_user_max_tag_id.keep_if { |tag_id| tag_id == latest_max_tag_id } #current_user_max_tag_idの中身を最新の最多タグに書き換え
    end

    current_user_tag_id = current_user_max_tag_id.join.to_i #配列から取り出し数値に変換
    current_user_tag_id_color = ActsAsTaggableOn::Tag.find(current_user_tag_id)[:color] #対応する色を取得
  end

end
