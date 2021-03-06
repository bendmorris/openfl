package openfl.filters; #if !flash #if !openfl_legacy


import openfl._internal.renderer.opengl.utils.RenderTexture;
import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if (js && html5)
import js.html.ImageData;
#end


/**
 * The BitmapFilter class is the base class for all image filter effects.
 *
 * <p>The BevelFilter, BlurFilter, ColorMatrixFilter, ConvolutionFilter,
 * DisplacementMapFilter, DropShadowFilter, GlowFilter, GradientBevelFilter,
 * and GradientGlowFilter classes all extend the BitmapFilter class. You can
 * apply these filter effects to any display object.</p>
 *
 * <p>You can neither directly instantiate nor extend BitmapFilter.</p>
 */

 @:access(openfl.display.BitmapData)
 @:access(openfl.geom.Rectangle)
class BitmapFilter {
	
	private var __dirty:Bool = true;
	private var __passes:Int = 0;
	private var __saveLastFilter:Bool = false;
	
	static private var __tmpRenderTexture:RenderTexture;
	
	public function new () {
		
		
		
	}
	
	
	/**
	 * Returns a BitmapFilter object that is an exact copy of the original
	 * BitmapFilter object.
	 * 
	 * @return A BitmapFilter object.
	 */
	public function clone ():BitmapFilter {
		
		return new BitmapFilter ();
		
	}
	
	
	#if (js && html5)
	@:noCompletion @:dox(hide) public function __applyFilter (sourceData:ImageData, targetData:ImageData, sourceRect:Rectangle, destPoint:Point):Void {
		
		
		
	}
	#end
	
	@:noCompletion private function __growBounds (rect:Rectangle) {
		
		
		
	}
	
	@:noCompletion private function __preparePass(pass:Int):Shader {
		return null;
	}
	
	@:noCompletion private function __useLastFilter(pass:Int):Bool {
		return false;
	}
	
	@:noCompletion private static function __expandBounds (filters:Array<BitmapFilter>, rect:Rectangle, matrix:Matrix) {
		
		var r = Rectangle.__temp;
		r.setEmpty();
		for (filter in filters) {
			filter.__growBounds (r);
		}
		
		r.__transform(r, matrix);
		rect.__expand(r.x, r.y, r.width, r.height);
	}
	
	@:noCompletion private static function __applyFilters (filters:Array<BitmapFilter>, renderSession:RenderSession, source:BitmapData, target:BitmapData, sourceRect:Rectangle, destPoint:Point) {

		var same = target == source && target.__usingPingPongTexture;
		if (same) target.__pingPongTexture.useOldTexture = true;
		
		if (sourceRect == null) sourceRect = source.rect;
		
		var lastFilterOutput = null;
		var useLastFilter = false;
		
		var srcShader = source.__shader;
		
		for (filter in filters) {
			useLastFilter = false;
			
			// if the filter needs the last filter output, swap and save a copy of it
			if (filter.__saveLastFilter) {
				target.__pingPongTexture.swap();
				target.__drawGL(renderSession, source, sourceRect, true, !target.__usingPingPongTexture, true);
				lastFilterOutput = target.__pingPongTexture.oldRenderTexture;
				target.__pingPongTexture.oldRenderTexture = __tmpRenderTexture;
			}
			
			for (pass in 0...filter.__passes) {
				
				useLastFilter = filter.__saveLastFilter && filter.__useLastFilter(pass);
				
				if (same && !useLastFilter) target.__pingPongTexture.swap();
				
				if (useLastFilter) {
					__tmpRenderTexture = target.__pingPongTexture.oldRenderTexture;
					target.__pingPongTexture.oldRenderTexture = lastFilterOutput;
				}
				
				source.__shader = filter.__preparePass(pass);
				target.__drawGL(renderSession, source, sourceRect, true, !target.__usingPingPongTexture, !useLastFilter);
			}
			
		}
		
		source.__shader = srcShader;
		
		if (same) target.__pingPongTexture.useOldTexture = false;
		
	}
	
	
}


#else
typedef BitmapFilter = openfl._legacy.filters.BitmapFilter;
#end
#else
typedef BitmapFilter = flash.filters.BitmapFilter;
#end