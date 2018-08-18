# README

## アプリケーション概要

**未知の音楽を、直感的に検索できるサービス**

各ユーザは、これまで聴いたことのあるアルバムに対し、それについての直感的な印象(例. 暖かい、赤い、悲しい など)のタグをつける。  
サービスの側で各アルバムごとにつけられたタグを集計し、可視化する。  
→そのアルバムがどんな印象を持たれがちな作品であるのかがわかる。

こうして見出されたアルバムの印象を、各ユーザはそれぞれの検索活動へと活用できる。

- 活用案1  
気になるアーティストがいるが、作品数が多いためどこから聴きはじめればいいかわからない。  
→まずは自分の好きないくつかの作品にタグをつけ、自分が好きな作品に対してどんな印象を抱きがちなのか、見つめ直す。  
気になるアーティストの作品一覧から、自分の抱きがちな印象のタグが多くついている作品を探し、そこから聴き始める。

- 活用案2  
自分が好む傾向の印象はすでに把握できているため、未知のアーティストのそういった作品を探したい。  
→タグ検索から、自分の好きな印象のタグが多くつけられた作品を片っ端から試してみる。

## ページ構成
[Top page](https://i.imgur.com/ehdTEFj.png)

[Artist page](https://i.imgur.com/609U2zU.png)

[Album page](https://i.imgur.com/arGXgw7.png)

[Tag page](https://i.imgur.com/jtl7r9S.png)

[User page](https://i.imgur.com/TT39mHU.png)

## アプリケーション要件

- artistテーブル  
各albumにはその作成者となるartistがいる。  
※コンピレーションアルバムなど、共作となる作品のために多対多とする。

- albumテーブル  
各albumは、各userのつけるtagによって評価される。  
※最大3つのタグがつく仕様とする。

- usersテーブル(deviseにより作成)  
各userは、deviseによるサインイン情報(email、password等)の他に、ユーザ名やアイコンを設定できる。

- tagsテーブル(acts-as-taggable-onにより作成)  
各userは、あらかじめ定義されたtagから最大3つを選び、albumの評価をする。

## DB設計

[ER図](https://i.imgur.com/Sw1dA9m.png)

### artistsテーブル

|Column|Type|Options|
|------|----|-------|
|name|text|null: false, foreign_key: true, add_index|

#### Association
- has_many :artist_albums
- has_many :albums, through: artist_albums

---

### artist_albumsテーブル

|Column|Type|Options|
|------|----|-------|
|artist_id|integer|null: false, foreign_key: true|
|album_id|integer|null: false, foreign_key: true|

#### Association
- has_many :artists
- has_many :albums

---

### albumsテーブル

|Column|Type|Options|
|------|----|-------|
|name|text|null: false, foreign_key: true, add_index|
|player|string|null: false|

#### Associasion
- has_many :artist_albums
- has_many :user_albums
- has_many :artists, through: artist_albums
- has_many :users, through: user_albums

---

### user_albumsテーブル

|Column|Type|Options|
|------|----|-------|
|album_id|integer|null: false, foreign_key: true|
|user_id|integer|foreign_key: true|

#### Association
- has_many :albums
- has_many :users

---

### usersテーブル

|Column|Type|Options|
|------|----|-------|
|name|text|null: false, unique: true|
|icon|string| |

#### Association
- has_many :user_albums
- has_many :taggings
- has_many :albums, through: user_albums
- has_many :tags, through: taggings

---

### tagsテーブル

|Column|Type|Options|
|------|----|-------|
|name|text|null: false, foreign_key: true, unique: true|
|taggings_count|integer| |

#### Association
- has_many :taggings
- has_many :albums, through: taggings
- has_many :users, through: taggings

---

### taggingsテーブル
※tagsテーブルとusersテーブル、albumsテーブル間の中間テーブル。acts-as-taggable-onにより作成。

|Column|Type|Options|
|------|----|-------|
|tag_id|integer|foreign_key: true|
|taggable_id|integer|foreign_key: true|

#### Assosiation
- has_many :users
- has_many :tags
- has_many :albums
