package com.ice5nake {
	
	function traceStage() : void {
		trace("**** stage info ****");
		trace("Number of children of the Stage: " + stage.numChildren);
		trace("What are children of Stage: " + stage.getChildAt(0));
		trace("Are this.stage and stage the same? " + (this.stage == stage));
		trace("How many children does this.stage have? " + this.stage.numChildren);
	}
}