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
    @album_spotify_id = TagsShowService.new(@tag).get_album_this_tag
    respond_to do |format|
      format.html
      format.json
    end
  end
end
