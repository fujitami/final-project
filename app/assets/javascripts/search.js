$(function () {

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
    var requireTokenUrl = 'https://accounts.spotify.com/api/token';

    // 検索機能のための変数定義
    var searchItemUrl = 'https://api.spotify.com/v1/search';
    // アーティスト検索用
    var artistSearchIndex = $('#artist-name-search__results');

    // アーティスト検索結果の描画
    function appendArtist(artistSearchHit) {
      var html =`<div class="artist-name-search__index list-group">
                  <a href="#" id=class="artist-name-search__artist-name" class="list-group-item list-group-item-active list-group-item-light" style="max-height: 50px">${ artistSearchHit }</a>
                </div>`
      artistSearchIndex.append(html);
    }

    // 新規アクセストークン取得
    function requireToken() {
      var requireTokenParams = {
        grant_type: 'refresh_token',
        refresh_token: refreshTokenVar
      }
      $.ajax({
        url: requireTokenUrl,
        type: 'POST',
        headers: {
          'Authorization': 'Basic ' + base64IdAndSecret
        },
        data: requireTokenParams,
        dataType: 'json'
      })
      .done(function(data) {
        accessToken = data.access_token;
      })
      .fail(function(data) {
        console.log('アクセストークンの有効期限が切れています。');
      });
    }

    // アーティスト検索
    $('#artist-name-search__form').on('keyup', function() {
      requireToken();
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
        $('.artist-name-search__index').empty();
        var artistSearchResult = data.artists.items;
        var artistSearchHit = artistSearchResult[0].name;
        if (artistSearchResult.length > 0) {
          appendArtist(artistSearchHit);
        }
      })
      .fail(function() {
        console.log('fail artist search')
      });
    });

  }

});
