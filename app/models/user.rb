class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :email, presence: true
  validates :name, presence: true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

# アイコン画像のサイズは仮置き、保存先はS3にする予定
  has_attached_file :icon, styles: { medium: "300x300#", thumb: "100x100#" }
  validates_attachment_content_type :icon,content_type: ["image/jpg","image/jpeg","image/png"]

end
