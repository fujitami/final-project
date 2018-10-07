class TagsController < ApplicationController
  before_action :authenticate_user!, only: [:show]

  # 検索用タグボタン一覧(トップページ)
  def index
    get_secrets
    get_latest_albums
    respond_to do |format|
      format.html
      format.json
    end
  end

  # タグ検索
  def show
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @album_spotify_id = TagsShowService.new(@tag).get_album_this_tag
    respond_to do |format|
      format.html
      format.json
    end
  end

  private

  # 秘匿情報の取得
  def get_secrets
    @client_id_and_secret = Rails.application.secrets.client_id_and_secret
    @refresh_token = Rails.application.secrets.refresh_token
  end

  # タグ付けされたアルバム最新10件の取得
  def get_latest_albums
    @latest_taggable_id = []
    Album.group(:spotify_id).order('id desc').first(10).each do |album|
      latest_album_spotify_id = Album.order('id desc').where('spotify_id = ?', album.spotify_id).maximum(:id)
      @latest_taggable_id << latest_album_spotify_id
    end

    @latest_spotify_id = LatestAlbumsService.new(@latest_taggable_id).get_latest_albums_spotify_id_5
    @latest_tag_id = LatestAlbumsService.new(@latest_taggable_id).get_latest_albums_tag_5
  end
end
