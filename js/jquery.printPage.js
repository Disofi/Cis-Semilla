/**
 * jQuery printPage Plugin
 * @version: 1.0
 * @author: Cedric Dugas, http://www.position-absolute.com
 * @licence: MIT
 * @desciption: jQuery page print plugin help you print your page in a better way
 */

(function( $ ){
  $.fn.printPage = function(options) {
    // EXTEND options for this button
    var pluginOptions = {
      attr : 'href',
      url : false,
      showMessage: true,
      message: 'Por favor espere mientras se genera la impresi&oacute;n' ,
      callback: null
    };
    $.extend(pluginOptions, options);

    this.on("click", 
    function(){  loadPrintDocument(this, pluginOptions); return false;  });
    
    /**
     * Load & show message box, call iframe
     * @param {jQuery} el - The button calling the plugin
     * @param {Object} pluginOptions - options for this print button
     */   
    function loadPrintDocument(el, pluginOptions){
      if(pluginOptions.showMessage){
      $("body").append(components.messageBox(pluginOptions.message));
      $("#printMessageBox").css("opacity", 0);
      $("#printMessageBox").animate({opacity:1}, 300, function() { addIframeToPage(el, pluginOptions); });
      } else {
        addIframeToPage(el, pluginOptions);
      }
    }
    /**
     * Inject iframe into document and attempt to hide, it, can't use display:none
     * You can't print if the element is not dsplayed
     * @param {jQuery} el - The button calling the plugin
     * @param {Object} pluginOptions - options for this print button
     */
    function addIframeToPage(el, pluginOptions){

        var url = (pluginOptions.url) ? pluginOptions.url : $(el).attr(pluginOptions.attr);

        if(!$('#printPage')[0]){
          $("body").append(components.iframe(url));
          $('#printPage').on("load",function() {  printit(pluginOptions);  });
        }else{
          $('#printPage').attr("src", url);
        }
    }
    /*
     * Call the print browser functionnality, focus is needed for IE
     */
    function printit(){
      frames.printPage.focus();
      frames.printPage.print();
      if(pluginOptions.showMessage){
        unloadMessage();
      }
      
      if($.isFunction(pluginOptions.callback))
      {
          $.call(this,pluginOptions.callback);
      }
      
    }
    /*
     * Hide & Delete the message box with a small delay
     */
    function unloadMessage(){
      $("#printMessageBox").delay(1000).animate({opacity:0}, 700, function(){
        $(this).remove();
      });
    }
    /*
     * Build html compononents for thois plugin
     */
    var components = {
      iframe: function(url){
          return '<iframe id="printPage" name="printPage" src='+url+' style="display: none; @media print { display: block; }"></iframe>';
       
      },
      messageBox: function(message){
        return "<div id='printMessageBox' style='\
          position:fixed;\
          top:50%; left:50%;\
          text-align:center;\
          margin: -60px 0 0 -155px;\
          width:400px; height:160px; font-size:13px; padding:10px; color:#333; font-family:helvetica, arial;\
          opacity:0;\
          background:#FFFFCC url(images/print-90x90.png) center 40px no-repeat;\
          border: 6px solid #666;\
          border-radius:8px; -webkit-border-radius:8px; -moz-border-radius:8px;\
          box-shadow:0px 0px 10px #888; -webkit-box-shadow:0px 0px 10px #888; -moz-box-shadow:0px 0px 10px #888'>\
          "+message+"</div>";
      }
    };
  };
})( jQuery );
