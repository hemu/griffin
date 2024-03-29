'use strict'

require('angular')
require('angular-cookies')
require('angular-resource')
require('angular-sanitize')
require('angular-route')
# require('angular-socket-io')
require('./game/game-route')

# Specify all module dependencies for our griffinApp.
angular.module 'griffinApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  # 'btford.socket-io',
  # 'ui.bootstrap',
  require('./game/game').name
  # The main client game module which contains all phaser code.
]
.config ($routeProvider, $locationProvider, $httpProvider) ->
  console.log "griffinApp config"
  $routeProvider
  # .otherwise
  #   redirectTo: '/'
  $locationProvider.html5Mode true
  $httpProvider.interceptors.push 'authInterceptor'

.factory 'authInterceptor', ($rootScope, $q, $cookieStore, $location) ->
  console.log "griffinApp authInterceptor"
  # Add authorization token to headers
  request: (config) ->
    config.headers = config.headers or {}
    config.headers.Authorization = 'Bearer ' + $cookieStore.get 'token' if $cookieStore.get 'token'
    config

  # Intercept 401s and redirect you to login
  responseError: (response) ->
    if response.status is 401
      $location.path '/login'
      # remove any stale tokens
      $cookieStore.remove 'token'

    $q.reject response

# .run ($rootScope, $location, Auth) ->
#   # Redirect to login if route requires auth and you're not logged in
#   $rootScope.$on '$routeChangeStart', (event, next) ->
#     Auth.isLoggedInAsync (loggedIn) ->
#       # $location.path "/login" if next.authenticate and not loggedIn