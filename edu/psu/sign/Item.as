package edu.psu.sign {
	import fl.controls.List;
	import fl.controls.listClasses.ICellRenderer;
	import fl.core.InvalidationType;
	import flash.display.*;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.xml.XMLDocument;
	import fl.controls.listClasses.ListData;
	import fl.core.UIComponent;
	import com.inordinatemind.*
	
	[Style(name="textFormat", type="flash.text.TextFormat")]
	[Style(name="padding", type="Number", format="Length")]
	[Style(name="bottom_margin", type="Number", format="Length")]

	public class Item extends UIComponent implements ICellRenderer{
		
		// Constants:
		// Public Properties:
			
		protected var _listData:ListData;
		protected var _data:Object;
		protected var _selected:Boolean = false;
		
		// Private Properties:
		private var textFields:Array;
		private var textField:TextField;
		private var bodyTextField:TextField;
		private static var defaultStyles:Object = {textFormat:null,padding:10,bottom_margin:5};
		
		// Initialization:
		public function Item() {
			textFields = new Array();
			super(); // Calls the UIComponent constructor
			
			var defaultFormat:TextFormat = new TextFormat();
			defaultFormat.font = "Verdana";
			defaultFormat.color = 0x2d2d2d;
			defaultFormat.align = "left";
			defaultFormat.size = 38;
			
			setStyle("textFormat", defaultFormat);
		}
		
		public static function getStyleDefinition():Object { return defaultStyles; }
		
		// Public Methods:
		override public function setSize(width:Number,height:Number):void {
			super.setSize(width, height);
			//Checking for title is dataSet specific
		}
		
		public function get listData():ListData {
			return _listData;
		}
		
		//TODO: Formatting should be set with setStyle
		public function set listData(value:ListData):void {
			_listData = value;
			
			var titleFormat:TextFormat = new TextFormat();
			titleFormat.font = "Arial";
			titleFormat.color = 0x000000;
			titleFormat.align = "left";
			titleFormat.bold = true;
			titleFormat.size = 52;
			setStyle("titleTextFormat", titleFormat);
			
			var tmpFormat:TextFormat = new TextFormat();
			tmpFormat.font = "Arial";
			tmpFormat.color = 0x000000;
			tmpFormat.align = "left";
			tmpFormat.bold = true;
			tmpFormat.size = 30;
			setStyle("timeTextFormat", tmpFormat);
			
			for (var property in data) {
				textFields[property] = new TextField();
				if (getStyleValue(property + "TextFormat")) {
					textFields[property].defaultTextFormat = getStyleValue(property + "TextFormat");
				} else {
					textFields[property].defaultTextFormat = getStyleValue("textFormat");	
				}
				textFields[property].text = data[property];
				
				var stripPattern:RegExp = /\(All Day\)/gi;
				textFields[property].text = textFields[property].text.replace(stripPattern, '');
				
				textFields[property].type = TextFieldType.DYNAMIC;
				textFields[property].selectable = false;
				if (property == 'time') {
					var date:Date = new Date();
					date.time = textFields[property].text * 1000; // Seconds to milliseconds
					textFields[property].text = date.toDateString();
				} else {
					textFields[property].text = new XMLDocument(data[property]).firstChild.nodeValue;
					
				}
				textFields[property].width = width;
			}
			
			// Text stroke setup
			var textFilter:GlowFilter = new GlowFilter;
			textFilter.blurX = textFilter.blurY = 6;
			textFilter.strength = 3;
			textFilter.color = 0xf4f4f4;
			
			textFields['title'].filters = [textFilter]
						
			setStyle("icon", _listData.icon);
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function set data(value:Object):void {
			_data = value;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean):void {
			if (_selected == value) { return; }
			_selected = value;
			invalidate(InvalidationType.STATE);
		}
				
		/*override public function setStyle(style:String, value:Object):void { 
        }*/
		
		public function setMouseState(state:String):void{ 
        }	
		
		// Protected Methods:
		
		override protected function configUI():void {
			super.configUI();
		}
		
		override protected function draw():void {
			super.draw();
			var textOverlay:MovieClip = new MovieClip();
			var g:Graphics = textOverlay.graphics;
			addChild(textOverlay);
			g.beginFill(0xdedede);
			g.lineStyle(1, 0x000033, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			g.drawRect(0,0,textFields['title'].width,(_listData.owner as List).rowHeight - Number(getStyleValue("bottom_margin")));
			g.endFill();
			textOverlay.alpha = 1;

			//These points seem to need to be calculated after super.draw() is called
			var tmp:Number = Number(getStyleValue("padding"));
			var tmpPoint:Point = localToGlobal( new Point(tmp, tmp) );
			textFields['time'].x = tmpPoint.x;
			textFields['time'].y = tmpPoint.y;
			
			tmpPoint = localToGlobal( new Point(tmp, 40) );
			textFields['title'].x = tmpPoint.x;
			textFields['title'].y = tmpPoint.y;
			
			tmpPoint = localToGlobal( new Point(tmp, 100) );
			textFields['result'].x = tmpPoint.x;
			textFields['result'].y = tmpPoint.y;
						
			//The text fields are added to the Sign not the Item or the List so they are 100% Opaque
			for (var field in textFields) {
				_listData.owner.parent.addChild(textFields[field]);
			}
 		}
	}
	
}