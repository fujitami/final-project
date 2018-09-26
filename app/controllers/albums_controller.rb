class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: [:create]

  def show
    @btn_disabled = 0
    respond_to do |format|
      format.html
      format.json {
        if Album.includes(:taggings).where("taggings.tagger_id = ?", current_user.id).references(:taggings).where(spotify_id: params[:id]).exists?
          @btn_disabled = 1
        end
      }
    end
  end

  # albumsテーブルにアルバム情報のレコード追加(タグ・ユーザとの関連付けも含む)
  def create
    render nothing: true
    @album = Album.new(spotify_id: params[:spotify_id])
    user = current_user
    unless Album.includes(:taggings).where("taggings.tagger_id = ?", current_user.id).references(:taggings).where(spotify_id: params[:spotify_id]).exists?
      tag_list = @album.tags_from(user)
      tag_list.add(@tag)
      user.tag(@album, with: tag_list, on: :tags)
    end
  end

  private

  def album_params
    params.require(:album).permit(
      :id,
      :spotify_id,
      users_attributes: [:id]
    )
  end

  def set_tag
    @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
  end

end
