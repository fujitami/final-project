# README

## アプリケーション概要

*未知の音楽を、直感的に検索できるサービス*

各ユーザは、これまで聴いたことのあるアルバムに対し、それについての直感的な印象(例. 暖かい、赤い、悲しい など)のタグをつける。

各アルバムごとにつけられたタグを集計し、可視化する。

→そのアルバムがどんな印象を持たれがちな作品であるのかがわかる。

こうして見出されたアルバムの印象を、各ユーザはそれぞれの検索活動へと活用できる。

- 活用案1

気になるアーティストがいるが、作品数が多いためどこから聴きはじめればいいかわからない。

→まずは自分の好きないくつかの作品にタグをつけ、自分が好きな作品に対してどんな印象を抱きがちなのか、見つめ直す。

気になるアーティストの作品一覧から、自分の抱きがちな印象のタグが多くついている作品を探し、そこから聴き始める。

- 活用案2

自分が抱きがちな印象はすでに把握できているため、未知のアーティストのそういった作品を探したい。

→タグ検索から、自分の好きな印象のタグが多くつけられた作品を片っ端から試してみる。

## アプリケーション要件

- artistテーブル
各albumにはその作成者となるartistがいる。
※コンピレーションアルバムなど、共作となる作品のために多対多とする。

- albumテーブル
各albumは、各userのつけるtagによって評価される。
※最大3つのタグがつく仕様とする。

- usersテーブル
各userは、deviseによるサインイン情報(email、password等)の他に、ユーザ名やアイコンを設定できる。

- tagsテーブル
tagはアプリケーション作成時に定義しておき、各userはその中から選んで評価をすることとなる。

## DB設計

### artistsテーブル

|Column|Type|Options|
|------|----|-------|
|artist_name|text|null: false, foreign_key: true, add_index|

#### Association
- has_many :albums, through: artist_albums

### artist_albumsテーブル

|Column|Type|Options|
|------|----|-------|
|artist_id|integer|null: false, foreign_key: true|
|album_id|integer|null: false, foreign_key: true|

#### Association
- belongs_to :album
- belongs_to :artist

### albumsテーブル

|Column|Type|Options|
|------|----|-------|
|album_name|text|null: false, foreign_key: true, add_index|
|album_URI|string|null: false|

#### Associasion
- has_many :artists, through: artist_albums
- has_many :users, through: user_albums

### album_usersテーブル

|Column|Type|Options|
|------|----|-------|
|album_id|integer|null: false, foreign_key: true|
|user_id|integer|foreign_key: true|

#### Association
- belongs_to :album
- belongs_to :user

### album_tagsテーブル

|Column|Type|Options|
|------|----|-------|
|album_id|integer|null: false, foreign_key: true|
|tag_id|integer|foreign_key: true|

#### Association
- belongs_to :album
- belongs_to :tag

### usersテーブル

|Column|Type|Options|
|------|----|-------|
|user_name|text|null: false, unique: true|
|user_icon|string| |

#### Association
- has_many :albums, through: user_albums
- has_many :tags, through: :tag_users

### tag_usersテーブル

|Column|Type|Options|
|------|----|-------|
|tag_id|integer|foreign_key: true|
|user_id|integer|null: false, foreign_key: true|

#### Association
- belongs_to :tag
- belongs_to :user

### tagsテーブル

|Column|Type|Options|
|------|----|-------|
|tag_name|text|null: false, foreign_key: true, unique: true|

#### Association
- has_many :albums, through: album_tags
- has_many :users, through: tag_users
