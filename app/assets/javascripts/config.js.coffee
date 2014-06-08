# angular.module('hypem').config([
#   '$urlRouterProvider',
#   '$stateProvider',
#   ($urlRouterProvider, $stateProvider) ->
#     $urlRouterProvider.otherwise('index')
#     $stateProvider
#       .state "index",
#         url: ""
#         controller: 'mainController'
#       .state "list",
#         url: "/lists/:listName"
#         controller: 'HypemController'
#         resolve:
#           list: ['$stateParams', ($stateParams) ->
#             $stateParams.listName
#           ]
#           tracks: ['$stateParams', 'hypemService', ($stateParams, hypemService) ->
#             return hypemService.fetch($stateParams.listName, $stateParams.seed, 0).then (data) ->
#              return data.data
#           ]
#         views:
#           '@':
#               templateUrl: 'content.html'
# ])

