package com.ice5nake {

	import flash.utils.*;
	
	public function traceObject(obj:*, traceChildren:Boolean = false) : void {
		var description:XML = describeType(obj);
		var headerInfo:Array = new Array();
		var propertiesInHeader = ['title', 'label', 'type', 'numChildren', 'width', 'height', 'x', 'y', 'parent'];
		for each(var propertyName in propertiesInHeader) {
			if (obj.hasOwnProperty(propertyName)) {
				headerInfo.push(propertyName + ": " + obj[propertyName]);
			}
		}
		trace("\n||* Start " + getQualifiedClassName(obj) + " - " + headerInfo.toString() + " *||\n" + 
			description.toXMLString() + 
			"\n||* End " + obj.toString() + " *||\n"
		);
		if (obj.hasOwnProperty('numChildren') && traceChildren) {
			for (var i:int = 0; i < obj.numChildren; i++ ) {
				var child = obj.getChildAt(i);
				if (child != null) {
					trace( "Tracing child " + child );
					traceObject(child);
				} else {
					trace( "!! Warning !! Child is null" );
				}
			}
		}
}

}
