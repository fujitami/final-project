class TagsController < ApplicationController
  def index
    @client_id_and_secret = Rails.application.secrets.client_id_and_secret
    @refresh_token = Rails.application.secrets.refresh_token
    respond_to do |format|
      format.html
      format.json
    end
  end
end
