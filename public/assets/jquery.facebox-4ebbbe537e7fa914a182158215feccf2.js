/*
 * Facebox (for jQuery)
 * version: 1.3
 * @requires jQuery v1.2 or later
 * @homepage https://github.com/defunkt/facebox
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright Forever Chris Wanstrath, Kyle Neath
 *
 * Usage:
 *
 *  jQuery(document).ready(function() {
 *    jQuery('a[rel*=facebox]').facebox()
 *  })
 *
 *  <a href="#terms" rel="facebox">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="facebox">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="facebox">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 *
 *    jQuery.facebox('some html')
 *    jQuery.facebox('some html', 'my-groovy-style')
 *
 *  The above will open a facebox with "some html" as the content.
 *
 *    jQuery.facebox(function($) {
 *      $.get('blah.html', function(data) { $.facebox(data) })
 *    })
 *
 *  The above will show a loading screen before the passed function is called,
 *  allowing for a better ajaxy experience.
 *
 *  The facebox function can also display an ajax page, an image, or the contents of a div:
 *
 *    jQuery.facebox({ ajax: 'remote.html' })
 *    jQuery.facebox({ ajax: 'remote.html' }, 'my-groovy-style')
 *    jQuery.facebox({ image: 'stairs.jpg' })
 *    jQuery.facebox({ image: 'stairs.jpg' }, 'my-groovy-style')
 *    jQuery.facebox({ div: '#box' })
 *    jQuery.facebox({ div: '#box' }, 'my-groovy-style')
 *
 *  Want to close the facebox?  Trigger the 'close.facebox' document event:
 *
 *    jQuery(document).trigger('close.facebox')
 *
 *  Facebox also has a bunch of other hooks:
 *
 *    loading.facebox
 *    beforeReveal.facebox
 *    reveal.facebox (aliased as 'afterReveal.facebox')
 *    init.facebox
 *    afterClose.facebox
 *
 *  Simply bind a function to any of these hooks:
 *
 *   $(document).bind('reveal.facebox', function() { ...stuff to do after the facebox and contents are revealed... })
 *
 */
!function(e){function o(o){if(e.facebox.settings.inited)return!0;e.facebox.settings.inited=!0,e(document).trigger("init.facebox"),n();var a=e.facebox.settings.imageTypes.join("|");e.facebox.settings.imageTypesRegexp=new RegExp("\\.("+a+")(\\?.*)?$","i"),o&&e.extend(e.facebox.settings,o),e("body").append(e.facebox.settings.faceboxHtml);var c=[new Image,new Image];c[0].src=e.facebox.settings.closeImage,c[1].src=e.facebox.settings.loadingImage,e("#facebox").find(".b:first, .bl").each(function(){c.push(new Image),c.slice(-1).src=e(this).css("background-image").replace(/url\((.+)\)/,"$1")}),e("#facebox .close").click(e.facebox.close).append('<img src="'+e.facebox.settings.closeImage+'" class="close_image" title="close">')}function a(){var e,o;return self.pageYOffset?(o=self.pageYOffset,e=self.pageXOffset):document.documentElement&&document.documentElement.scrollTop?(o=document.documentElement.scrollTop,e=document.documentElement.scrollLeft):document.body&&(o=document.body.scrollTop,e=document.body.scrollLeft),new Array(e,o)}function c(){var e;return self.innerHeight?e=self.innerHeight:document.documentElement&&document.documentElement.clientHeight?e=document.documentElement.clientHeight:document.body&&(e=document.body.clientHeight),e}function n(){var o=e.facebox.settings;o.loadingImage=o.loading_image||o.loadingImage,o.closeImage=o.close_image||o.closeImage,o.imageTypes=o.image_types||o.imageTypes,o.faceboxHtml=o.facebox_html||o.faceboxHtml}function t(o,a){if(o.match(/#/)){var c=window.location.href.split("#")[0],n=o.replace(c,"");if("#"==n)return;e.facebox.reveal(e(n).html(),a)}else o.match(e.facebox.settings.imageTypesRegexp)?i(o,a):f(o,a)}function i(o,a){var c=new Image;c.onload=function(){e.facebox.reveal('<div class="image"><img src="'+c.src+'" /></div>',a)},c.src=o}function f(o,a){e.facebox.jqxhr=e.get(o,function(o){e.facebox.reveal(o,a)})}function s(){return 0==e.facebox.settings.overlay||null===e.facebox.settings.opacity}function l(){return s()?void 0:(0==e("#facebox_overlay").length&&e("body").append('<div id="facebox_overlay" class="facebox_hide"></div>'),e("#facebox_overlay").hide().addClass("facebox_overlayBG").css("opacity",e.facebox.settings.opacity).click(function(){e(document).trigger("close.facebox")}).fadeIn(200),!1)}function d(){return s()?void 0:(e("#facebox_overlay").fadeOut(200,function(){e("#facebox_overlay").removeClass("facebox_overlayBG"),e("#facebox_overlay").addClass("facebox_hide"),e("#facebox_overlay").remove()}),!1)}e.facebox=function(o,a){e.facebox.loading(o.settings||[]),o.ajax?f(o.ajax,a):o.image?i(o.image,a):o.div?t(o.div,a):e.isFunction(o)?o.call(e):e.facebox.reveal(o,a)},e.extend(e.facebox,{settings:{opacity:.2,overlay:!0,loadingImage:"/assets/facebox/loading-a297497bfa40d2c5dfa8b8408d497bef.gif",closeImage:"/assets/facebox/closelabel-14303ebeb2def0d6fb54778e6a60b4ae.png",imageTypes:["png","jpg","jpeg","gif"],faceboxHtml:'    <div id="facebox" style="display:none;">       <div class="popup">         <div class="content">         </div>         <a href="#" class="close"></a>       </div>     </div>'},loading:function(){return o(),1==e("#facebox .loading").length?!0:(l(),e("#facebox .content").empty().append('<div class="loading"><img src="'+e.facebox.settings.loadingImage+'"/></div>'),e("#facebox").show().css({top:a()[1]+c()/10,left:e(window).width()/2-e("#facebox .popup").outerWidth(!0)/2}),e(document).bind("keydown.facebox",function(o){return 27==o.keyCode&&e.facebox.close(),!0}),e(document).trigger("loading.facebox"),void 0)},reveal:function(o,a){e(document).trigger("beforeReveal.facebox"),a&&e("#facebox .content").addClass(a),e("#facebox .content").empty().append(o),e("#facebox .popup").children().fadeIn("normal"),e("#facebox").css("left",e(window).width()/2-e("#facebox .popup").outerWidth()/2),e(document).trigger("reveal.facebox").trigger("afterReveal.facebox")},close:function(){return e(document).trigger("close.facebox"),!1}}),e.fn.facebox=function(a){function c(){e.facebox.loading(!0);var o=this.rel.match(/facebox\[?\.(\w+)\]?/);return o&&(o=o[1]),t(this.href,o),!1}if(0!=e(this).length)return o(a),this.bind("click.facebox",c)},e(document).bind("close.facebox",function(){e.facebox.jqxhr&&(e.facebox.jqxhr.abort(),e.facebox.jqxhr=null),e(document).unbind("keydown.facebox"),e("#facebox").fadeOut(function(){e("#facebox .content").removeClass().addClass("content"),e("#facebox .loading").remove(),e(document).trigger("afterClose.facebox")}),d()})}(jQuery);