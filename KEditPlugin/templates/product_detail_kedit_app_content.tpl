<!--{if $arrProduct.plg_kedit_flg}-->



<script type="text/javascript">

	$(document).ready(function(){
        var KEditApp = {
            appIdentify: "KEditApp",
            isBrowserSupported: true,
        	isKEditAppLoaded: false,
        	exportedDataInputId: '#kEditExportedDataInput',
        	exportedFinishMessageTagId: '#kEditFinishMessage',
            exportedFinishPreviewId: '#kEditFinishPreview',
        	iFrameId: '#kEditAppIFrame',
        	iFramePath: "<!--{$app_path}-->",
        	iframe: {},
        	iFrameWindow: {},
            uploadApi: "<!--{$upload_api}-->",
            productListApi: "<!--{$product_list_api}-->",
            
            resize: function() {
            	var height = $(window).height();
            	var width = $(window).width();
            	$(this.iframe).css({
            		'width': width,
            		'height': height
            	});
            },

            checkSupport: function(){
                var self = this;
                if(typeof(Storage) !== "undefined") {
                    // Code for localStorage/sessionStorage.
                } else {
                    
                    self.errorMessage = "Sorry! No Web Storage support..";
                }
            },

        	init: function() {

        		var self = this;
                // self.checkSupport();
                // if (!isBrowserSupported) {
                //     alert(self.errorMessage);
                //     return;
                // }

        		self.iframe = $('<iframe />', {
				    id: self.iFrameId
				})[0];
				$(self.iframe).css({
					'display': 'none',
					'position': 'absolute',
		            'top': 0,
		            'left': 0,
		            'background-color': 'black',
		            'z-index': 1000
				}).appendTo('body');

        		self.isKEditAppLoaded = false;
        		
        		$(self.iframe).hide();
        		$(window).resize(function(){
        			self.resize();
        		});
        		self.resize();

        		// trigger load
        		var onLoadHandler = function() {
        			
	        		self.app = self.iFrameWindow 
	        		         = self.iframe.contentWindow;
	        		
	        		if (!self.app.setupAppData) {
	        			self.onLoadFail("setupAppData func not foud in iframe-window.");
	        			return;
	        		}

	        		self.app.setupAppData({
	        			data: {},
	        			callback: function(data) {
	        				self.onFinish(data);
	        			}
	        		});
	        		self.isKEditAppLoaded = true;
	        		console.log("[app: " +  self.appIdentify + "] load success " + self.isKEditAppLoaded);
        		};
                var unix = Math.round(+new Date()/1000);
                var appPath = self.iFramePath + '?v=' + unix
        		$(self.iframe).attr('src', appPath);
        		$(self.iframe).bind('load', onLoadHandler);
        	},
        	start: function() {
        		var self = this;

        		if (!self.isKEditAppLoaded) {
        			console.log("app cannot startup.");
        			return;
        		}
        		if (!self.app.startup) {
        			console.log("app::startup function not found.");
        			return;
        		}
                $(window).scrollTop(0);
        		$(self.iframe).fadeIn();

        		self.app.startup();
        	},
        	onFinish: function(data) {
        		var self = this;
        		self.fillData(data);
                self.saveTempData(data, function(err){
                    $(self.iframe).fadeOut();
                });
        	},
        	preData: function() {
        	},
        	fillData: function(data) {
        	},
            saveTempData: function(data, callback){
                var transactionid = $("*[name=transactionid]").val();
                var product_id = data["product_id"];
                var exported_data_url = data['exported_data_url'];
                var template_url = data['template_url'];
                var encodedContentData = encodeURIComponent(exported_data_url);
                var uploadTempApiUrl = this.uploadApi;

                console.log("transactionid: " + transactionid);

                $.ajax({
                    
                    type: "POST",
                    ulr: uploadTempApiUrl,
                    data: { 
                        'transactionid': transactionid, 
                        'kedit_product_id': product_id,
                        'kedit_template_url': template_url,
                        'kedit_exported_data_url': encodedContentData,
                        'kedit_summit': true 
                    },
                    success: function(data){
                        //alert(data );
                        var d = JSON.parse(data);
                        var url = decodeURIComponent(d['url']);
                        if (callback) callback();
                    },
                    error: function(xhr,status,error) {
                        //alert(error);
                        console.log(error);

                        if (callback) callback(error);
                    }
                });
            },
        	onLoadFail: function(err) {
        		console.log("KEdit App Load Error " + err);
        	}
        }
        KEditApp.init();

		$("#start-kedit-app-btn").click(function(){
			if (!KEditApp.isKEditAppLoaded) {
				console.log("KEditAppLoaded Fail..");
				return;
			}
			KEditApp.start();
		});
	});
</script>

<!--{/if}-->