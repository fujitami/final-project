$(function () {

  window.onpageshow = function(event) {
    if (event.persisted) {
      location.reload();
    }
  }

  // 秘匿情報取得
  $(function getSecrets() {
    $.ajax({
      url: '/tags',
      type: 'GET',
      dataType: 'json'
    })
    .done(function(data){
      search(data);
    })
    .fail(function(){
    })
  });

  // 検索機能
  function search(secrets) {

    // 秘匿情報関係の変数定義
    var clientIdAndSecretVar = secrets.clientIdAndSecret;
    var base64IdAndSecret = window.btoa(clientIdAndSecretVar);
    var accessToken = '';
    var refreshTokenVar = secrets.refreshToken;
    const proxyurl = 'https://gentle-beyond-92284.herokuapp.com/';
    const requireTokenUrl = 'https://accounts.spotify.com/api/token';

    // 検索機能のための変数定義
    // アーティスト検索(GET https://api.spotify.com/v1/search)
    const searchItemUrl = 'https://api.spotify.com/v1/search';
    var artistSearchIndex = $('#artist-name-search__results');
    // アーティスト詳細(GET https://api.spotify.com/v1/artists/{id})及びアルバム検索(GET https://api.spotify.com/v1/artists/{id}/albums)
    const searchArtistInfoUrl = 'https://api.spotify.com/v1/artists/';
    // アルバム検索(GET https://api.spotify.com/v1/albums/{id})
    const searchAlbumInfoUrl = 'https://api.spotify.com/v1/albums/';

    // アルバム一覧の描画(アーティスト詳細・タグ検索結果・マイページ共通で使用予定)
    function appendAlbumIndex(albumThumbUrl, albumName, albumId, tagId) {
      var artistAlbumIndex = $('.album-index__lists');
      var albumShowUrl = '/albums/' + albumId;
      var html = `<li class="album-index__list list-inline-item mx-3 pt-3">
                    <button class="album-index__btn btn ${ addTagColor(tagId) }" type="button" onclick="location.href='${ albumShowUrl }'">
                      <div class="album-index__thumbnail--wrapper">
                        <img class="album-index__thumbnail img-thumbnail" src=${ albumThumbUrl }>
                      </div>
                    </button>
                    <p class="album-index__name text-center d-block text-truncate">${ albumName }</p>
                  </li>`
      artistAlbumIndex.append(html);
    }

    // アルバムに設定されたタグのidによって.album-index__btnにボタンの色を設定するクラスを追加
    function addTagColor(tagId) {
      switch (tagId) {
        case 1:
          return 'btn-orange400';
          break;
        case 2:
          return 'btn-red400';
          break;
        case 3:
          return 'btn-indigo400';
          break;
        case 4:
          return 'btn-yellow400';
          break;
        case 5:
          return 'btn-purple400';
          break;
        case 6:
          return 'btn-grey400';
          break;
        case 7:
          return 'btn-white';
          break;
        default:
          return 'btn-outline-dark';
          break;
      }
    }

    // ページ表示時にアクセストークン取得
    if (location.host.match(/^localhost:3000$/) || location.hostname.match(/^www\.discovermusiconfeelings\.com$/)) {
      requireToken();
    }

    // 新規アクセストークン取得
    function requireToken() {
      var requireTokenParams = {
        grant_type: 'refresh_token',
        refresh_token: refreshTokenVar
      }
      $.ajax({
        url: proxyurl + requireTokenUrl,
        type: 'POST',
        headers: {
          'Authorization': 'Basic ' + base64IdAndSecret
        },
        data: requireTokenParams,
        dataType: 'json'
      })
      .done(function(data) {
        accessToken = data.access_token;
        if (location.pathname.match(/\/artists\/([a-zA-Z0-9]{22})$/)) { //アーティスト詳細ページにいる際の処理
          var spotifyArtistId = location.pathname.split('/')[2];
          artistInfo(accessToken, spotifyArtistId);
          artistAlbumIndex(accessToken, spotifyArtistId);
        } else if (location.pathname.match(/\/albums\/([a-zA-Z0-9]{22})$/)) { //アルバム詳細ページにいる際の処理
          var spotifyAlbumId = location.pathname.split('/')[2];
          albumInfo(accessToken, spotifyAlbumId);
        } else if (location.pathname.match(/\/tags\/([a-zA-Z0-9]*)$/)) { //タグ検索ページにいる時の処理
          tagSearch(accessToken);
        } else if (location.pathname.match(/\/users\/([a-zA-Z0-9]*)$/)) { //マイページにいる時の処理
          mypageShow(accessToken);
        } else if (location.host.match(/^localhost:3000$/) || location.hostname.match(/^www\.discovermusiconfeelings\.com$/) || location.pathname.match(/\/tags\/$/)) { //トップページにいる時の処理
          latestAlbumsSearch(accessToken);
        }
      })
      .fail(function(data) {
        console.log('アクセストークンの有効期限が切れています。');
      });
    }

    // アーティスト検索
    $('#artist-name-search__form').on('keyup', function() {
      var input = $('#artist-name-search__form').val();
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      var artistSearchParams = {
        q: input,
        type: 'artist',
        market: 'JP'
      }
      $.ajax({
        url: searchItemUrl,
        type: 'GET',
        headers: authorizationCode,
        data: artistSearchParams,
        dataType: 'json'
      })
      .done(function(data) {
        $('.artist-name-search__index').remove();
        var artistSearchResult = data.artists.items;
        var artistSearchResultName = artistSearchResult[0].name;
        if (artistSearchResult.length > 0) {
          appendArtist(artistSearchResultName);
          moveToArtistShow(artistSearchResult);
        }
      })
      .fail(function() {
      });
    });

    // アーティスト検索結果の描画
    function appendArtist(artistname) {
      var html =`<div class="artist-name-search__index list-group">
                  <a id="artist-name-search__artist-name" class="list-group-item list-group-item-active list-group-item-light" style="max-height: 50px" data-turbolinks="false">${ artistname }</a>
                </div>`
      artistSearchIndex.append(html);
    }

    // アーティスト詳細ページへの遷移
    function moveToArtistShow(artist) {
      $('#artist-name-search__results').on('click', '#artist-name-search__artist-name', function() {
        location.href = '/artists' + '/' + artist[0].id;
      });
    }

    // 最新の投稿10件を検索
    function latestAlbumsSearch(accessToken) {
      var latestSpotifyId = secrets.latest_spotify_id;
      var latestTagId = secrets.latest_tag_id;
      for (i=0; i<latestSpotifyId.length; i++) {
        latestAlbumsIndex(accessToken, latestSpotifyId[i], latestTagId[i]);
      }
    }

    // 最新の投稿一覧取得
    function latestAlbumsIndex(accessToken, latestSpotifyId, latestTagId) {
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchAlbumInfoUrl + latestSpotifyId,
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        var latestAlbum = data;
        var albumThumbUrl = latestAlbum.images[0].url;
        var albumName = latestAlbum.name;
        var albumId = latestAlbum.id;
        appendAlbumIndex(albumThumbUrl, albumName, albumId, latestTagId);
      })
      .fail(function(){
      });
    }

    // アーティスト詳細ページへのビュー追加(アーティスト名、アルバム情報)
    // アーティスト詳細情報の取得
    function artistInfo(accessToken, spotifyArtistId) {
      var artistNameSearch = $('#artist-name-search');
      var artistNameSearchTitle = $('#artist-name-search__title');
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchArtistInfoUrl + spotifyArtistId,
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        var artistName = `<h2 class="align-middle">${ data.name }</h2>`
        var artistImg = data.images[0].url
        artistNameSearchTitle.append(artistName);
        artistNameSearch.css('background-image', 'url(' + artistImg + ')');
      })
      .fail(function(){
      });
    }

    // 当該アーティストのアルバム一覧取得
    function artistAlbumIndex(accessToken, spotifyArtistId) {
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchArtistInfoUrl + spotifyArtistId + '/albums',
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        var artistAlbums = data.items;
        for (i=0; i<artistAlbums.length; i++) {
          var albumThumbUrl = artistAlbums[i].images[0].url;
          var albumName = artistAlbums[i].name;
          var albumId = artistAlbums[i].id;
          artistAlbumsTag(albumThumbUrl, albumName, albumId);
        }
      })
      .fail(function(){
      });
    }

    // アーティストの各アルバムについて、最も多くついたタグを可視化
    function artistAlbumsTag(albumThumbUrl, albumName, albumId) {
      $.ajax({
        url: '/artists/tagged/' + albumId,
        type: 'POST',
        dataType: 'json'
      })
      .done(function(data) {
        var tagId = data.tagId
        appendAlbumIndex(albumThumbUrl, albumName, albumId, tagId);
      })
      .fail(function(){
      });
    }

    // アルバム詳細情報の取得
    function albumInfo(accessToken, spotifyAlbumId) {
      buttonDisabled(spotifyAlbumId);
      var albumSearchUpper = $('#album-search--upper');
      var albumSearchTitle = $('#album-search__title');
      var spotifyPlayer = $('#spotify-player');
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchAlbumInfoUrl + spotifyAlbumId,
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        var albumName = `<h2 class="align-middle">${ data.name }</h2>`;
        var albumImg = data.images[0].url;
        albumSearchTitle.append(albumName);
        albumSearchUpper.css('background-image', 'url(' + albumImg + ')');
        spotifyPlayer.attr('src', ('https://open.spotify.com/embed/album/' + spotifyAlbumId));
        taggingAlbum(spotifyAlbumId);
      })
      .fail(function(){
      });
    }

    // ログイン中ユーザによって既にタグ付け済みのアルバムのタグボタンを無効に
    function buttonDisabled(albumId) {
      if (location.pathname.match(/\/albums\/([a-zA-Z0-9]{22})$/)) {
        $.ajax({
          url: '/albums/' + albumId,
          type: 'GET',
          dataType: 'json',
          cache: false
        })
        .done(function(data){
          if (data.btn_disabled == 1) {
            $('.album-search_tag--btn').addClass('disabled');
          }
        })
        .fail(function(){
        })
      }
    }

    // アルバムへのタグ付与(albums#create)
    function taggingAlbum(spotifyAlbumId) {
      $('.album-search_tag--btn').click(function() {
        var buttonVal = $(this).val();
        $('.album-search_tag--btn').prop('disabled', true);
        $.ajax({
          url: '/albums',
          type: 'POST',
          data: {
            spotify_id: spotifyAlbumId,
            tag_id: buttonVal
          }
        })
        .done(function(){
        })
        .fail(function(){
        });
      });
    }


    // タグ検索(tags#show)
    function tagSearch(accessToken) {
      var tagId = location.pathname.split('/')[2];
      $.ajax({
        url: '/tags/' + tagId,
        type: 'GET',
        dataType: 'json',
        cache: false
      })
      .done(function(data){
        var tagAlbums = data;
        for (i=0; i<tagAlbums.length; i++) {
          tagAlbumsIndex(accessToken, tagAlbums[i].spotifyAlbumId, tagId);
        }
      })
      .fail(function(){
      });
    }

    // タグ検索結果一覧に表示するアルバム取得
    function tagAlbumsIndex(accessToken, spotifyAlbumId, tagId) {
      tagId = Number(tagId); //文字列として渡されてきたため数値に変換
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchAlbumInfoUrl + spotifyAlbumId,
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        var tagAlbum = data;
        var albumThumbUrl = tagAlbum.images[0].url;
        var albumName = tagAlbum.name;
        var albumId = tagAlbum.id;
        appendAlbumIndex(albumThumbUrl, albumName, albumId, tagId);
      })
      .fail(function(){
      });
    }

    // マイページの表示
    function mypageShow(accessToken) {
      $.ajax({
        url: location.href,
        type: 'GET',
        dataType: 'json',
        cache: false
      })
      .done(function(data) {
        var currentUserAlbums = data.album;
        var currentUserMypage = $('#current-user-mypage');
        for (i=0; i<currentUserAlbums.length; i++) {
          currentUserAlbumsIndex(accessToken, currentUserAlbums[i].spotifyAlbumId, currentUserAlbums[i].tagId);
        }
        currentUserMypage.css('background-color', data.current_user_color);
      })
      .fail(function(){
      });
    }

    // マイページに表示するアルバム一覧取得(タグ色はユーザの選んだものを表示)
    function currentUserAlbumsIndex(accessToken, spotifyAlbumId, tagId) {
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchAlbumInfoUrl + spotifyAlbumId,
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        var currentUserAlbum = data;
        var albumThumbUrl = currentUserAlbum.images[0].url;
        var albumName = currentUserAlbum.name;
        var albumId = currentUserAlbum.id;
        appendAlbumIndex(albumThumbUrl, albumName, albumId, tagId);
      })
      .fail(function(){
      });
    }

  }

});
