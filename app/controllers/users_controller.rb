class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    user = current_user
    @album_ids_hash = UsersShowService.new(user).get_album_ids
    respond_to do |format|
      format.html
      format.json
    end
  end

end
