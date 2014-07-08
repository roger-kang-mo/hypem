# angular.module("hypem").directive "ngEnter", ->
#   (scope, element, attrs) ->
#     element.bind "keydown keypress", (event) ->
#       if event.which is 13
#         scope.$apply ->
#           scope.$eval attrs.ngEnter
#           return

#         event.preventDefault()
#       return

#     return

angular.module("hypem").directive "focusInput", [ '$timeout', ($timeout) ->
  link: (scope, element, attrs) ->
    element.bind "click", ->
      $timeout ->
        element.next('form').children('input').focus()
]


angular.module('hypem').directive "hmPopover", ['$compile', '$templateCache', ($compile, $templateCache) ->
  restrict: "A"
  transclude: false
  scope: false

  link: (scope, element, attrs) ->
    popoverContent = ""
    html = $templateCache.get(attrs.hmPopover)
    popoverContent = $compile(html)(scope)

    options =
      content: popoverContent
      placement: "bottom"
      html: true
      container: 'body'

    closePopover = (event, currentPopoverParent = null) ->
      hasPopover = angular.element('.js-popover-open')
      if hasPopover.length > 0
        hasPopover = hasPopover.not(currentPopoverParent) if currentPopoverParent
        hasPopover.removeClass('js-popover-open').popover('hide')
      else
        angular.element('.popover').hide()

    bodyClickHandler = (event) =>
        event.stopPropagation()
        event.stopImmediatePropagation()

        angular.element('body:not(.popover), .dropdown-toggle').unbind('click.popoverOpenBodyClick')
        closePopover(event)

    confirmPopover = (event) =>
      clickedElement = angular.element(event.target)
      functionToCall = clickedElement.data('confirm-method')
      scope[functionToCall](event) if functionToCall
      closePopover(event)

    angular.element(element).popover options

    angular.element(element).click (event) ->
      html = $templateCache.get(attrs.hmPopover)
      popoverContent = $compile(html)(scope)

      # angular.element(element).data('popover').options.content = popoverContent

      clickedElement = angular.element(event.target)
      clickedElementClass = clickedElement.attr('class')
      popover = angular.element('.popover')

      # Closes the dropdown menu and moves the popover up
      if clickedElementClass && clickedElementClass.match(/js-dropdown-element/)
        dropdownToggle = clickedElement.parents('.dropdown-menu').prev()
        adjustedHeight = dropdownToggle.offset().top + 32

        dropdownToggle.click()
        popover.offset(top: adjustedHeight)

      popoverStylingClass = clickedElement.data('popover-styling')
      popover.addClass(popoverStylingClass)

      clickedElement.addClass('js-popover-open')
      closePopover(event, clickedElement)

      angular.element("body:not(.popover), .dropdown-toggle").bind 'click.popoverOpenBodyClick', (event) =>
        clickedElement = angular.element(event.target)
        bodyClickHandler(event) if clickedElement.parents('.popover').length == 0 && !clickedElement.attr('class').match(/js-add-to-playlist/)

      angular.element('.js-confirm-popover').click (event) =>
        confirmPopover(event)

      angular.element('.js-close-popover').click (event) =>
        closePopover(event)

      true
]