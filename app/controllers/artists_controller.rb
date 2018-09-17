class ArtistsController < ApplicationController
  before_action :authenticate_user!

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end
end
