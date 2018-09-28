class TagsController < ApplicationController
  before_action :authenticate_user!, only: [:show]

  # 検索用タグボタン一覧(トップページ)
  def index
    @client_id_and_secret = Rails.application.secrets.client_id_and_secret
    @refresh_token = Rails.application.secrets.refresh_token
    respond_to do |format|
      format.html
      format.json
    end
  end

  # タグ検索
  def show
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    # taggingsに関連するalbumsテーブルから当該タグがついているレコードを取得し、さらにspotify_idカラムの値が同じものを集計→当該タグの付与されたアルバムを抽出
    album_this_tag = Album.includes(:taggings).where("taggings.tag_id = ?", @tag.id).references(:taggings).group(:spotify_id)
    album_this_tag_count = album_this_tag.count()

    # 上記に含まれるアルバムのうち、ついているタグの中で当該タグが最も多くを占めているものを配列hitsに入れる
    hits = []

    # 当該タグ以外のタグを抽出し、当該タグの付与されたアルバムに他のタグが付与されているか確認
    other_tag_id = ActsAsTaggableOn::Tag.pluck(:id).reject{ |n| n == @tag.id }
    other_tag_id.each do |other_tag_id|
      album_other_tag_count = Album.includes(:taggings).where("taggings.tag_id = ?", other_tag_id).where(spotify_id: album_this_tag_count.keys).references(:taggings).group(:spotify_id).count()
      # アルバムに付与されたタグの数を比較し、配列に追加するか判定
      n_dup = 0
      album_this_tag.where(spotify_id: album_other_tag_count.keys).count().values.each do |album_this_tag_value|
        if album_this_tag_value > album_other_tag_count.values[n_dup]
          hits << album_other_tag_count.keys[n_dup]
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

    # 配列hitsの重複・nil整理
    @album_spotify_id = hits.uniq.compact
    respond_to do |format|
      format.html
      format.json
    end
  end
end
