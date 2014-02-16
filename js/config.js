'use strict';

$(document).ready(function() {
  window.message = new Message({area: "#messages", title: "#messages .messages-title", mode: "production"});

  window.app = new App({
    canvas: {
      area: "#prevArea",
      background: ".canvas-background",
      resizeCallback: function (e,ui) {
        var $updateArea = $(".canvas-updates");
        if ($updateArea.hasClass("l-hidden")) {
          $updateArea.removeClass("l-hidden").hide().fadeIn();
        }
        $updateArea.text("width: " + ui.size.width + ", height: " + ui.size.height);
      },
      stopCallback: function (e,ui) {
        var $updateArea = $(".canvas-updates");
        $updateArea.fadeOut(400, function() {
          $(this).addClass("l-hidden");
        });
      }
    },
    code: {
      area: "#codeArea",
      code: "#code code",
      filter: ".selected",
      data: "value",
      format: "#codeStyle",
      fileName: "cssspritepro"
    },
    download: {
      anchor: "#downloadLink",
      fileName: "cssspritepro"
    },
    save: {
      anchor: "#save",
      fileName: "cssspritepro"
    },
    buttons: {
      fit:    "#fit",
      convert: "#convert",
      clear: "#clear",
      save: "#save",
      load: "#load",
      loadInput: "#loadInput"
    },
    canvasIconTooltip: {
      $tooltip: $("#canvasIconsActions"),
      addToLeft: 15,
      addToTop: 50,
      buttons: {
        deleteIcon: "#deleteIcon"
      }
    },
    reRenderCallback: function (e, ui) {
      //graphical settings
      var widthChange = ui.size.width - ui.originalSize.width;
      var heightChange = ui.size.height - ui.originalSize.height;

      var canvasBackground = ui.element.closest(".canvas-container").find(".canvas-background");
      canvasBackground.width(canvasBackground.width() + widthChange);
      canvasBackground.height(canvasBackground.height() + heightChange);
    },
    iconOnloadCallback: function () {
      var $CodePlaceholder =  $("#codeArea .code-placeholder");
      var $CodeElements = $("#codeArea pre, #copyAll");
      if (!$CodePlaceholder.hasClass("l-hidden")) {
        $CodePlaceholder.addClass("l-hidden");
        $CodeElements.removeClass("l-hidden");
      }
    }
  });


  /* -------------
   Get Code
   ---------------- */

  var $elements = $(".code-select-el");

  var showHideElements = function(e) {
    e.stopPropagation();
    e.preventDefault();

    if ($elements.closest(".code-select").hasClass("is-closed")) {
      // I want to select
      $elements.closest(".code-select").removeClass("is-closed");

      $elements.slideDown();
    }
    else {
      // I've selected an Item
      $elements.closest(".code-select").addClass("is-closed");

      $elements.removeClass("selected");
      $(this).addClass("selected");
      $(this).trigger("formatCodeSelected");

      $elements.not(this).slideUp();
    }
  }

  $elements.on("click", showHideElements);
  /* End Get Code */

  /* -------------
   Top Menu
   ---------------- */
  var time = 400;
  var $menuElements = $(".js-menuElement");
  var showHideMenuElements = function($menuElement) {
    if (!$menuElement.closest("li").hasClass("is-open")) {
      //show element
      $menuElement.siblings().removeClass("l-hidden").hide().slideDown(time, function() {
        $menuElement.closest("li").addClass("is-open");

        $("body").on("click.menuElement", function() {
          //hide elements
          $(this).off(".menuElement");
          $menuElements.each(function() {
            var $menuElement = $(this);
            $menuElement.siblings().slideUp(time, function() {
              $menuElement.siblings().addClass("l-hidden");
              $menuElement.closest("li").removeClass("is-open");
            });
          });
        });
      });
    }
    else {
      //hide element
      $menuElement.siblings().slideUp(time, function() {
        $menuElement.siblings().addClass("l-hidden");
        $menuElement.closest("li").removeClass("is-open");
      });
    }
  };

  $menuElements.click(function(e) {
    e.stopPropagation();
    e.preventDefault();

    showHideMenuElements($(this));
  });

  $("#help").click(function(e){
    e.stopPropagation();
    e.preventDefault();

    guiders.show("guider1");
  });

  /* End Top Menu */
});
