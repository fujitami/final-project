class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :email, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: :false }, length: { minimum: 4, maximum: 10 }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # アカウント更新時にパスワードを要求しないためのメソッド
  def update_without_current_password(params)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params)
    clean_up_passwords
    result
  end

  # アイコン画像の設定
  has_attached_file :icon,
    styles: { medium: "300x300#", thumb: "100x100#" },
    default_url: '/assets/kakikunsq.png'
  validates_attachment_content_type :icon,content_type: ["image/jpg","image/jpeg","image/png"]

  # acts-as-taggable-onの関連付け(tagger)
  acts_as_tagger
end
