class TagsShowService
  def initialize(tag)
    @this_tag = tag
  end

  def get_album_this_tag
    # taggingsに関連するalbumsテーブルから当該タグ(@this_tag.id)がついているレコードを取得し、さらにspotify_idカラムの値が同じものを集計→当該タグの付与されたアルバムを抽出
    album_this_tag = Album.includes(:taggings).where('taggings.tag_id = ?', @this_tag.id).references(:taggings).group(:spotify_id)
    album_this_tag_count = album_this_tag.count()

    # 上記に含まれるアルバムのうち、ついているタグの中で当該タグが最も多くを占めているものを配列hitsに入れる
    hits = []

    # 当該タグ以外のタグを抽出し、当該タグの付与されたアルバムに他のタグが付与されているか確認
    other_tag_id = ActsAsTaggableOn::Tag.pluck(:id).reject{ |n| n == @this_tag.id }
    other_tag_id.each do |other_tag_id|
      album_other_tag_count = Album.includes(:taggings).where('taggings.tag_id = ?', other_tag_id).where(spotify_id: album_this_tag_count.keys).references(:taggings).group(:spotify_id).count()
      # アルバムに付与されたタグの数を比較し、ページに表示するアルバムのspotify_idの入る配列hitsに追加するか判定
      # 当該タグがついたアルバムの中で、現在確認中のタグ(other_tag_id)がついたものを抽出し、各アルバムにおけるその回数を抜き出してeachにかける
      n_dup = 0
      album_this_tag.where(spotify_id: album_other_tag_count.keys).count().values.each do |album_this_tag_value|
        checking_album_id = album_other_tag_count.keys[n_dup] # 現在確認中のアルバムのspotify_id
        if album_this_tag_value > album_other_tag_count.values[n_dup] # 当該タグの方が多く付与されている場合→現在確認中のアルバムを表示
          hits << checking_album_id
        else album_this_tag_value == album_other_tag_count.values[n_dup] # 同数付与されたタグが存在する場合→より最近タグ付けされたアルバムを表示
          latest_tagging_id = Album.order('id desc').where('spotify_id = ?', checking_album_id).maximum(:id)
          latest_tagging_tag_id = ActsAsTaggableOn::Tagging.where('taggable_id = ?', latest_tagging_id).pluck(:tag_id).join.to_i # pluckだと配列の形で出力されるため、数値に直す
          if @this_tag.id == latest_tagging_tag_id
            hits << checking_album_id
          end
        end
        n_dup += 1
      end

    end

    # 当該タグのみが付与されたアルバムを配列に追加
    n_only = 0
    album_all_tag_count = Album.includes(:taggings).where(spotify_id: album_this_tag_count.keys).references(:taggings).group(:spotify_id).count()
    album_all_tag_count.values.each do |album_all_tag_count|
      if album_all_tag_count == album_this_tag_count.values[n_only]
        hits << album_this_tag_count.keys[n_only]
      end
      n_only += 1
    end

    # 配列hitsの重複・nil整理、ランダム表示、表示件数指定
    album_spotify_id = hits.uniq.compact.shuffle.take(10)

  end

end
