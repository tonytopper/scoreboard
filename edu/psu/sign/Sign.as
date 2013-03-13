package edu.psu.sign {
	import fl.data.DataProvider;
	import flash.display.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.xml.XMLDocument;
	import fl.controls.List;
	import mx.core.MovieClipLoaderAsset
	import com.adobe.serialization.json.JSON;
	import edu.psu.sign.Item;
	import com.inordinatemind.*
	
	public class Sign extends MovieClip {
		
		// Public Properties:
		
		// Protected Properties:
		protected var _url:String;
		protected var _background:String;
		protected var _title:String;
		
		// Private Properties:
		private var displayComponent:List;
		private var titleTextField:TextField;
		private var provider:DataProvider;
		private var loaders:Array;
		
		[Embed(source='/assets/logo.svg')]
		private var BackgroundVectorGraphic:Class;
		private var backgroundLogo:Sprite = new BackgroundVectorGraphic();
		//private var background_logo:SVGViewerFlash;
		
		private const CONTENT_WIDTH:Number = 1852
		private const LIGHT_ANGLE:Number = 45
		private const CONTENT_MARGIN:Number = 34
		private const LOGO_PATH:String = "http://webtools.hbg.psu.edu/signs/assets/logo.png"
		private const HEADER_PATH:String = "http://webtools.hbg.psu.edu/signs/assets/header.swf"
		
		public function Sign( webServiceUrl:String = null ) {
			url = webServiceUrl;
			_init();
			_configureSign();
		}
				
		public function get url():String {
			return _url;
		}
		
					public function set url(value:String):void {
			if (value != url) {
				_url = value;
				loadJson();
			}
		}
		
		public function get background():String {
			return _background;
		}
		
		public function set background(value:String):void {
			_background = value;
			loaders['background'].contentLoaderInfo.addEventListener(Event.COMPLETE, backgroundLoadComplete);
			loaders['background'].load( new URLRequest( _background ) );
		}
		
		public function get title():String {
			return _title;
		}
		
		public function set title(value:String):void {
			_title = value;
			titleTextField.text = _title;
			
			var titleTextFormat:TextFormat = new TextFormat();
			titleTextFormat.font = "Arial";
			titleTextFormat.color = 0xffffff;
			titleTextFormat.align = "left";
			titleTextFormat.bold = true;
			titleTextFormat.size = 56;
					
			titleTextField.setTextFormat(titleTextFormat);
		}
		
		private function _init() {
			stop();
			this.loaders = new Array();
			this.displayComponent = new List();
			this.provider = new DataProvider();
			
			addEventListener(Event.ADDED_TO_STAGE, _addedHandler);
			
			loaders['background'] = new Loader();
			loaders['header'] = new Loader();
			loaders['logo'] = new Loader();
			
			addChild( loaders['background'] );
			addChild( backgroundLogo ); // Using Flek Embed
			addChild( loaders['header'] );
			addChild( loaders['logo'] );
			
			loaders['header'].contentLoaderInfo.addEventListener(Event.COMPLETE, headerLoadComplete);
			loaders['header'].load( new URLRequest( HEADER_PATH ) );
			
		}
		
		private function _addedHandler(e) {
			//The stage object will exist now
			_configureBackgroundLogo();
		}
		
		private function _configureSign() {
			displayComponent.labelFunction = getLabelFieldContent;
			
			displayComponent.dataProvider = provider;
			displayComponent.selectable = false;
			displayComponent.setStyle("contentPadding", 10);
			displayComponent.setSize( CONTENT_WIDTH, 750 );
			displayComponent.move( CONTENT_MARGIN, 290 );
			displayComponent.alpha = .5;
			displayComponent.setStyle("cellRenderer", Item);
			
			loaders['logo'].x = CONTENT_MARGIN;
			loaders['logo'].y = loaders['logo'].x;
			loaders['logo'].load( new URLRequest( LOGO_PATH ) );
			
			_configureTitle();
			
		}
		
		private function _configureBackgroundLogo() : void {
			backgroundLogo.alpha = .5;
			backgroundLogo.blendMode = BlendMode.NORMAL;
			backgroundLogo.width = backgroundLogo.width * 3.5;
			backgroundLogo.height = backgroundLogo.height * 3.5;
			backgroundLogo.x = Math.floor((stage.stageWidth - backgroundLogo.width) / 2);;
			backgroundLogo.y = 100;
			var logoShadow:DropShadowFilter;
			logoShadow = new DropShadowFilter(
				5,
				LIGHT_ANGLE,
				0x000000,
				1,
				4,
				4,
				1,
				BitmapFilterQuality.LOW,
				false,
				false,
				false);
			
			backgroundLogo.filters = [logoShadow];			
		}
		
		private function _configureTitle() {
			var mcb:MovieClip = new MovieClip();
			mcb.x = CONTENT_MARGIN;
			mcb.y = CONTENT_MARGIN + 145 + CONTENT_MARGIN;
			var matr:Matrix = new Matrix();
			matr.createGradientBox(200, 20, Math.PI / 2, 0, 0);
			mcb.graphics.beginGradientFill(GradientType.LINEAR, [0x0c2b5c,0x0f3b6c], [1,.9], [0,255], matr);
			mcb.graphics.lineStyle(1, 0x000033, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			mcb.graphics.drawRect(0, 0, CONTENT_WIDTH, 73);
			mcb.graphics.endFill();
			addChild(mcb);
			//trace("Adding title box which is child #" + numChildren);
			
			titleTextField = new TextField();
			mcb.addChild(titleTextField);
			
			var dropShadow:DropShadowFilter;
			dropShadow = new DropShadowFilter(
				2,
				LIGHT_ANGLE,
				0x000000,
				1,
				4,
				4,
				1,
				BitmapFilterQuality.MEDIUM,
				true,
				false,
				false
			);
			
			titleTextField.filters = [dropShadow];
			
			titleTextField.x = 10;
			titleTextField.width = titleTextField.parent.width;
		}
		
		private function backgroundLoadProgress(e:ProgressEvent) : void {
			var percentLoaded:Number = e.bytesLoaded/e.bytesTotal;
			percentLoaded = Math.round(percentLoaded * 100);
		}
		
		private function backgroundLoadComplete(e) : void {
			trace("Background load complete, " + e.target.content.width + " x " + e.target.content.height);
			
			if (e.target.content.height < e.target.content.width) {
				e.target.content.width = stage.stageWidth;
				e.target.content.scaleY = e.target.content.scaleX;
			} else {
				e.target.content.height = stage.stageHeight;
				e.target.content.scaleX = e.target.content.scaleY;
			}
			e.target.content.alpha = 1;
			var blur:BlurFilter;
			blur = new BlurFilter(
				8,
				8,
				BitmapFilterQuality.LOW);

			e.target.content.filters = [blur];
		}
		
		private function headerLoadComplete(e:Event) : void {
			e.target.content.alpha = .75;
			e.target.content.blendMode = BlendMode.NORMAL;
			
			trace('Layered load complete, ' + e.target.content.width + " x " + e.target.content.height + " at " + e.target.content.x + ", " + e.target.content.y);
		}
		
		private function loadJson():void {
			//TODO: Figure out how to cache this locally
			var jsonLoader:URLLoader = new URLLoader();
			jsonLoader.addEventListener(Event.COMPLETE, onJsonComplete);
			jsonLoader.load( new URLRequest( url ) );
		}  
		
		private function onJsonComplete(e:Event):void {
			trace('JSON loading completed.');
			var decodedData = JSON.decode(e.target.data, false);
			for (var index in decodedData.nodes) {
				provider.addItem(decodedData.nodes[index].node);
			}
			//TODO: This is too big for some reason.
			displayComponent.rowHeight = Math.floor( (displayComponent.height - 2 * (displayComponent.getStyle("contentPadding") as Number)) / decodedData.nodes.length);
			addChild(displayComponent);
		}
		
		function getLabelFieldContent(item:Object):String {
			return new XMLDocument(item.title).firstChild.nodeValue;
		}
		
	}
}