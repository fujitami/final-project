$(function () {

  // 秘匿情報取得
  $(function getSecrets() {
    $.ajax({
      url: '/tags',
      type: 'GET',
      dataType: 'json'
    })
    .done(function(data){
      console.log(data);
      search(data);
    })
    .fail(function(){
      console.log('fail getSecrets');
    })
  });

  // 検索機能
  function search(secrets) {

    // 秘匿情報関係の変数定義
    var clientIdAndSecretVar = secrets.clientIdAndSecret;
    var base64IdAndSecret = window.btoa(clientIdAndSecretVar);
    var accessToken = '';
    var refreshTokenVar = secrets.refreshToken;
    var proxyurl = 'https://cors-anywhere.herokuapp.com/';
    var requireTokenUrl = 'https://accounts.spotify.com/api/token';
    console.log(refreshTokenVar);

    // 検索機能のための変数定義
    // アーティスト検索(GET https://api.spotify.com/v1/search)
    var searchItemUrl = 'https://api.spotify.com/v1/search';
    var artistSearchIndex = $('#artist-name-search__results');
    // アーティスト詳細(GET https://api.spotify.com/v1/artists/{id})及びアルバム検索(GET https://api.spotify.com/v1/artists/{id}/albums)
    var searchArtistInfoUrl = 'https://api.spotify.com/v1/artists/';

    // アルバム一覧の描画(アーティスト詳細・タグ検索結果・マイページ共通で使用予定)
    function appendAlbumIndex(albumThumbUrl, albumName) {
      var artistAlbumIndex = $('.album-index__lists');
      var html = `<li class="album-index__list list-inline-item mx-3 pt-3">
                    <button class="album-index__btn btn btn-orange400" type="button" onclick="location.href='#'">
                      <div class="album-index__thumbnail--wrapper">
                        <img class="album-index__thumbnail img-thumbnail" src=${ albumThumbUrl }>
                      </div>
                    </button>
                    <p class="album-index__name text-center d-block text-truncate">${ albumName }</p>
                  </li>`
      artistAlbumIndex.append(html);
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
          var spotifyId = location.pathname.split('/')[2];
          artistInfo(accessToken, spotifyId);
          artistAlbumIndex(accessToken, spotifyId);
        } else {
          console.log('fail id');
        }
      })
      .fail(function(data) {
        console.log('アクセストークンの有効期限が切れています。');
      });
    }

    // アーティスト検索
    $('#artist-name-search__form').on('keyup', function() {
      if(location.pathname.match(/\/$/) || location.pathname.match(/\/tags\/$/)) {
        requireToken();
      } else {}
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
        console.log('fail artist search');
      });
    });

    // アーティスト検索結果の描画
    function appendArtist(artistname) {
      var html =`<div class="artist-name-search__index list-group">
                  <a id="artist-name-search__artist-name" class="list-group-item list-group-item-active list-group-item-light" style="max-height: 50px">${ artistname }</a>
                </div>`
      artistSearchIndex.append(html);
    }

    // アーティスト詳細ページへの遷移
    function moveToArtistShow(artist) {
      $('#artist-name-search__results').on('click', '#artist-name-search__artist-name', function() {
        location.href = '/artists' + '/' + artist[0].id;
      });
    }

    // アーティスト詳細ページへのビュー追加(アーティスト名、アルバム情報)
    // アーティスト詳細ページでのアクセストークン取得
    if (location.pathname.match(/\/artists\/([a-zA-Z0-9]{22})$/)) {
      requireToken();
    }

    // アーティスト詳細情報の取得
    function artistInfo(accessToken, spotifyId) {
      var artistNameSearch = $('#artist-name-search');
      var artistNameSearchTitle = $('#artist-name-search__title');
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchArtistInfoUrl + spotifyId,
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        console.log(data);
        var artistName = `<h2 class="align-middle">${ data.name }</h2>`
        var artistImg = data.images[0].url
        artistNameSearchTitle.append(artistName);
        artistNameSearch.css('background-image', 'url(' + artistImg + ')');
      })
      .fail(function(){
        console.log('fail info');
      });
    }

    // 当該アーティストのアルバム一覧取得
    function artistAlbumIndex(accessToken, spotifyId) {
      var authorizationCode = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      }
      $.ajax({
        url: searchArtistInfoUrl + spotifyId + '/albums',
        type: 'GET',
        headers: authorizationCode,
        dataType: 'json'
      })
      .done(function(data){
        console.log(data.items[0]);
        console.log(data.items[0].images[0].url);
        var artistAlbums = data.items;
        for (i=0; i<artistAlbums.length; i++) {;
          var albumThumbUrl = artistAlbums[i].images[0].url;
          var albumName = artistAlbums[i].name;
          appendAlbumIndex(albumThumbUrl, albumName);
        }
      })
      .fail(function(){
        console.log('fail album');
      });
    }

  }

});
