require 'rails_helper'

describe TagsController, type: :controller do
  describe 'GET #show' do
    it 'renders the :show template' do
      tag = create(:tag)
      get :show, params: {id: tag}
      expect(response).to render_template :show
    end
  end
  describe 'GET #index' do
    it 'renders the :index template' do
      get :index
      expect(response).to render_template :index
    end
  end
end
