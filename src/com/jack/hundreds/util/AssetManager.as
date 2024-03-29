package com.jack.hundreds.util
{
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.FileReference;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.ImageDecodingPolicy;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.clearTimeout;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import flash.utils.setTimeout;
    
    import starling.core.Starling;
    import starling.text.BitmapFont;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    
    /** The AssetManager handles loading and accessing a variety of asset types. You can 
     *  add assets directly (via the 'add...' methods) or asynchronously via a queue. This allows
     *  you to deal with assets in a unified way, no matter if they are loaded from a file, 
     *  directory, URL, or from an embedded object.
     *  
     *  <p>If you load files from disk, the following types are supported:</p>
     *  <code>png, jpg, atf, mp3, xml, fnt</code> 
     */    
    public class AssetManager
    {
        private const SUPPORTED_EXTENSIONS:Vector.<String> = 
            new <String>["png", "jpg", "jpeg", "atf", "mp3", "xml", "fnt"]; 
        
        private var mScaleFactor:Number;
        private var mGenerateMipmaps:Boolean;
        private var mVerbose:Boolean;
        
        private var mRawAssets:Array;
        private var mTextures:Dictionary;
        private var mAtlases:Dictionary;
        private var mSounds:Dictionary;
		private var mXmls:Dictionary;	// not include the sprite sheet xml
        
        /** helper objects */
        private var sNames:Vector.<String> = new <String>[];
        
        /** Create a new AssetManager. The 'scaleFactor' and 'createMipmaps' parameters define
         *  how enqueued bitmaps will be converted to textures. */
        public function AssetManager(scaleFactor:Number=-1, createMipmaps:Boolean=false)
        {
            mVerbose = false;
            mScaleFactor = scaleFactor > 0 ? scaleFactor : Starling.contentScaleFactor;
            mGenerateMipmaps = createMipmaps;
            mRawAssets = [];
            mTextures = new Dictionary();
            mAtlases = new Dictionary();
            mSounds = new Dictionary();
			mXmls = new Dictionary();
        }
        
        /** Disposes all contained textures. */
        public function dispose():void
        {
            for each (var texture:Texture in mTextures)
                texture.dispose();
            
            for each (var atlas:TextureAtlas in mAtlases)
                atlas.dispose();
        }
        
        // retrieving
        
        /** Returns a texture with a certain name. The method first looks through the directly
         *  added textures; if no texture with that name is found, it scans through all 
         *  texture atlases. */
        public function getTexture(name:String):Texture
        {
            if (name in mTextures) return mTextures[name];
            else
            {
                for each (var atlas:TextureAtlas in mAtlases)
                {
                    var texture:Texture = atlas.getTexture(name);
                    if (texture) 
						return texture;
					else
					{
						var ts:Vector.<Texture> = atlas.getTextures(name);
						if(ts && ts.length == 1)
							return ts[0];
					}
                }
                return null;
            }
        }
        
        /** Returns all textures that start with a certain string, sorted alphabetically
         *  (especially useful for "MovieClip"). */
        public function getTextures(prefix:String="", result:Vector.<Texture>=null):Vector.<Texture>
        {
            if (result == null) result = new <Texture>[];
            
            for each (var name:String in getTextureNames(prefix, sNames))
                result.push(getTexture(name));
            
            sNames.length = 0;
            return result;
        }
        
        /** Returns all texture names that start with a certain string, sorted alphabetically. */
        public function getTextureNames(prefix:String="", result:Vector.<String>=null):Vector.<String>
        {
            if (result == null) result = new <String>[];
            
            for (var name:String in mTextures)
                if (name.indexOf(prefix) == 0)
                    result.push(name);                
            
            for each (var atlas:TextureAtlas in mAtlases)
                atlas.getNames(prefix, result);
            
            result.sort(Array.CASEINSENSITIVE);
            return result;
        }
        
        /** Returns a texture atlas with a certain name, or null if it's not found. */
        public function getTextureAtlas(name:String):TextureAtlas
        {
            return mAtlases[name] as TextureAtlas;
        }
        
        /** Returns a sound with a certain name. */
        public function getSound(name:String):Sound
        {
            return mSounds[name];
        }
		
		/** Returns a xml with a certain name. */
		public function getXml(name:String):XML
		{
			return mXmls[name];
		}
        
        /** Returns all sound names that start with a certain string, sorted alphabetically. */
        public function getSoundNames(prefix:String=""):Vector.<String>
        {
            var names:Vector.<String> = new <String>[];
            
            for (var name:String in mSounds)
                if (name.indexOf(prefix) == 0)
                    names.push(name);
            
            return names.sort(Array.CASEINSENSITIVE);
        }
        
        /** Generates a new SoundChannel object to play back the sound. This method returns a 
         *  SoundChannel object, which you access to stop the sound and to monitor volume. */ 
        public function playSound(name:String, startTime:Number=0, loops:int=0, 
                                  transform:SoundTransform=null):SoundChannel
        {
            if (name in mSounds)
                return getSound(name).play(startTime, loops, transform);
            else 
                return null;
        }
        
        // direct adding
        
        /** Register a texture under a certain name. It will be availble right away. */
        public function addTexture(name:String, texture:Texture):void
        {
            log("Adding texture '" + name + "'");
            
            if (name in mTextures)
                throw new Error("Duplicate texture name: " + name);
            else
                mTextures[name] = texture;
        }
        
        /** Register a texture atlas under a certain name. It will be availble right away. */
        public function addTextureAtlas(name:String, atlas:TextureAtlas):void
        {
            log("Adding texture atlas '" + name + "'");
            
            if (name in mAtlases)
                throw new Error("Duplicate texture atlas name: " + name);
            else
                mAtlases[name] = atlas;
        }
        
        /** Register a sound under a certain name. It will be availble right away. */
        public function addSound(name:String, sound:Sound):void
        {
            log("Adding sound '" + name + "'");
            
            if (name in mSounds)
                throw new Error("Duplicate sound name: " + name);
            else
                mSounds[name] = sound;
        }
        
        // removing
        
        /** Removes a certain texture, optionally disposing it. */
        public function removeTexture(name:String, dispose:Boolean=true):void
        {
            if (dispose && name in mTextures)
                mTextures[name].dispose();
            
            delete mTextures[name];
        }
        
        /** Removes a certain texture atlas, optionally disposing it. */
        public function removeTextureAtlas(name:String, dispose:Boolean=true):void
        {
            if (dispose && name in mAtlases)
                mAtlases[name].dispose();
            
            delete mAtlases[name];
        }
        
        /** Removes a certain sound. */
        public function removeSound(name:String):void
        {
            delete mSounds[name];
        }
		
		/** Removes a certain xml. */
		public function removeXml(name:String):void
		{
			delete mXmls[name];
		}
        
        /** Removes assets of all types and empties the queue. */
        public function purge():void
        {
            for each (var texture:Texture in mTextures)
                texture.dispose();
            
            for each (var atlas:TextureAtlas in mAtlases)
                atlas.dispose();
            
            mRawAssets.length = 0;
            mTextures = new Dictionary();
            mAtlases = new Dictionary();
            mSounds = new Dictionary();
			mXmls = new Dictionary();
        }
        
        // queued adding
        
        /** Enqueues one or more raw assets; they will only be available after successfully 
         *  executing the "loadQueue" method. This method accepts a variety of different objects:
         *  
         *  <ul>
         *    <li>Strings containing an URL to a local or remote resource. Supported types:
         *        <code>png, jpg, atf, mp3, fnt, xml</code> (texture atlas).</li>
         *    <li>Instances of the File class (AIR only) pointing to a directory or a file.
         *        Directories will be scanned recursively for all supported types.</li>
         *    <li>Classes that contain <code>static</code> embedded assets.</li>
         *  </ul>
         *  
         *  Suitable object names are extracted automatically: A file named "image.png" will be
         *  accessible under the name "image". When enqueuing embedded assets via a class, 
         *  the variable name of the embedded object will be used as its name. An exception
         *  are texture atlases: they will have the same name as the actual texture they are
         *  referencing.
         */
        public function enqueue(...rawAssets):void
        {
            for each (var rawAsset:Object in rawAssets)
            {
                if (rawAsset is Array)
                {
                    enqueue.apply(this, rawAsset);
                }
                else if (rawAsset is Class)
                {
                    var typeXml:XML = describeType(rawAsset);
                    var childNode:XML;
                    
                    if (mVerbose)
                        log("Looking for static embedded assets in '" + 
                            (typeXml.@name).split("::").pop() + "'"); 
                    
                    for each (childNode in typeXml.constant.(@type == "Class"))
                        push(rawAsset[childNode.@name], childNode.@name);
                    
                    for each (childNode in typeXml.variable.(@type == "Class"))
                        push(rawAsset[childNode.@name], childNode.@name);
                }
                else if (getQualifiedClassName(rawAsset) == "flash.filesystem::File")
                {
                    if (!rawAsset["isHidden"])
                    {
                        if (rawAsset["isDirectory"])
                            enqueue.apply(this, rawAsset["getDirectoryListing"]());
                        else
                        {
                            var extension:String = rawAsset["extension"].toLowerCase();
                            if (SUPPORTED_EXTENSIONS.indexOf(extension) != -1)
                                push(rawAsset["url"]);
                            else
                                log("Ignoring unsupported file '" + rawAsset["name"] + "'");
                        }
                    }
                }
                else if (rawAsset is String)
                {
                    push(rawAsset);
                }
                else
                {
                    log("Ignoring unsupported asset type: " + getQualifiedClassName(rawAsset));
                }
            }
            
            function push(asset:Object, name:String=null):void
            {
                if (name == null) name = getName(asset);
                log("Enqueuing '" + name + "'");
                
                mRawAssets.push({ 
                    name: name, 
                    asset: asset 
                });
            }
        }
        
        /** Loads all enqueued assets asynchronously. The 'onProgress' function will be called
         *  with a 'ratio' between '0.0' and '1.0', with '1.0' meaning that it's complete.
         *
         *  @param onProgress: <code>function(ratio:Number):void;</code> 
         */
        public function loadQueue(onProgress:Function):void
        {
            if (Starling.context == null)
                throw new Error("The Starling instance needs to be ready before textures can be loaded.");
            
            var xmls:Vector.<XML> = new <XML>[];
            var numElements:int = mRawAssets.length;
            var currentRatio:Number = 0.0;
            var timeoutID:uint;
            
            resume();
            
            function resume():void
            {
                currentRatio = 1.0 - (mRawAssets.length / numElements);
                
                if (mRawAssets.length)
                    timeoutID = setTimeout(processNext, 1);
                else
                    processXmls();
                
                if (onProgress != null)
                    onProgress(currentRatio);
            }
            
            function processNext():void
            {
                var assetInfo:Object = mRawAssets.pop();
                clearTimeout(timeoutID);
                loadRawAsset(assetInfo.name, assetInfo.asset, xmls, progress, resume);
            }
            
            function processXmls():void
            {
                // xmls are processed seperately at the end, because the textures they reference
                // have to be available for other XMLs. Texture atlases are processed first:
                // that way, their textures can be referenced, too.
                
                xmls.sort(function(a:XML, b:XML):int { 
                    return a.localName() == "TextureAtlas" ? -1 : 1; 
                });
                
                for each (var xml:XML in xmls)
                {
                    var name:String;
                    var rootNode:String = xml.localName();
                    
                    if (rootNode == "TextureAtlas")
                    {
                        name = getName(xml.@imagePath.toString());
                        
                        var atlasTexture:Texture = getTexture(name);
                        addTextureAtlas(name, new TextureAtlas(atlasTexture, xml));
                        removeTexture(name, false);
                    }
                    else if (rootNode == "font")
                    {
                        name = getName(xml.pages.page.@file.toString());
                        
                        var fontTexture:Texture = getTexture(name);
                        TextField.registerBitmapFont(new BitmapFont(fontTexture, xml));
                        removeTexture(name, false);
                    }
					else if (rootNode == "Layout") 
					{
						name = getName(xml.@path.toString());
						
						mXmls[name] = xml;
					}
                    else
                        throw new Error("XML contents not recognized: " + rootNode);
                }
            }
            
            function progress(ratio:Number):void
            {
                onProgress(currentRatio + (1.0 / numElements) * Math.min(1.0, ratio) * 0.99);
            }
        }
        
        private function loadRawAsset(name:String, rawAsset:Object, xmls:Vector.<XML>,
                                      onProgress:Function, onComplete:Function):void
        {
            var extension:String = null;
            
            if (rawAsset is Class)
            {
                var asset:Object = new rawAsset();
                
                if (asset is Sound)
                    addSound(name, asset as Sound);
                else if (asset is Bitmap)
                    addTexture(name, 
                        Texture.fromBitmap(asset as Bitmap, mGenerateMipmaps, false, mScaleFactor));
                else if (asset is ByteArray)
                {
                    var bytes:ByteArray = asset as ByteArray;
                    var signature:String = String.fromCharCode(bytes[0], bytes[1], bytes[2]);
                    if (signature == "ATF")
                        addTexture(name, Texture.fromAtfData(asset as ByteArray, mScaleFactor));
                    else
                        xmls.push(new XML(bytes));
                }
                
                onComplete();
            }
            else if (rawAsset is String)
            {
                var url:String = rawAsset as String;
                extension = String(url.split(".").pop()).toLowerCase();
                
                var urlLoader:URLLoader = new URLLoader();
                urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
                urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
                urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
                urlLoader.load(new URLRequest(url));
            }
            
            function onIoError(event:IOErrorEvent):void
            {
                log("IO error: " + event.text);
                onComplete();
            }
            
            function onLoadProgress(event:ProgressEvent):void
            {
                onProgress(event.bytesLoaded / event.bytesTotal);
            }
            
            function onUrlLoaderComplete(event:Event):void
            {
                var urlLoader:URLLoader = event.target as URLLoader;
                var bytes:ByteArray = urlLoader.data as ByteArray;
                var sound:Sound;
                
                urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
                urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
                
                switch (extension)
                {
                    case "atf":
                        addTexture(name, Texture.fromAtfData(bytes, mScaleFactor));
                        onComplete();
                        break;
                    case "fnt":
                    case "xml":
                        xmls.push(new XML(bytes));
                        onComplete();
                        break;
                    case "mp3":
                        sound = new Sound();
                        sound.loadCompressedDataFromByteArray(bytes, bytes.length);
                        addSound(name, sound);
                        onComplete();
                        break;
                    default:
                        var loaderContext:LoaderContext = new LoaderContext();
                        var loader:Loader = new Loader();
                        loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
                        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
                        loader.loadBytes(urlLoader.data as ByteArray, loaderContext);
                        break;
                }
            }
            
            function onLoaderComplete(event:Event):void
            {
                event.target.removeEventListener(Event.COMPLETE, onLoaderComplete);
                var content:Object = event.target.content;
                
                if (content is Bitmap)
                    addTexture(name,
                        Texture.fromBitmap(content as Bitmap, mGenerateMipmaps, false, mScaleFactor));
                else
                    throw new Error("Unsupported asset type: " + getQualifiedClassName(content));
                
                onComplete();
            }
        }
        
        // helpers
        
        private function getName(rawAsset:Object):String
        {
            var matches:Array;
            var name:String;
            
            if (rawAsset is String || rawAsset is FileReference)
            {
                name = rawAsset is String ? rawAsset as String : (rawAsset as FileReference).name;
                name = name.replace(/%20/g, " "); // URLs use '%20' for spaces
                matches = /(.*[\\\/])?([\w\s\-]+)(\.[\w]{1,4})?/.exec(name);
                
                if (matches && matches.length == 4) return matches[2];
                else throw new ArgumentError("Could not extract name from String '" + rawAsset + "'");
            }
            else
            {
                name = getQualifiedClassName(rawAsset);
                throw new ArgumentError("Cannot extract names for objects of type '" + name + "'");
            }
        }
        
        private function log(message:String):void
        {
            if (verbose) trace("[AssetManager]", message);
        }
        
        // properties
        
        /** When activated, the class will trace information about added/enqueued assets. */
        public function get verbose():Boolean { return mVerbose; }
        public function set verbose(value:Boolean):void { mVerbose = value; }
        
        /** Indicates if mipMaps should be generated for textures created from Bitmaps. */ 
        public function get generateMipMaps():Boolean { return mGenerateMipmaps; }
        public function set generateMipMaps(value:Boolean):void { mGenerateMipmaps = value; }
        
        /** Textures that are created from Bitmaps will have the scale factor assigned here. */
        public function get scaleFactor():Number { return mScaleFactor; }
        public function set scaleFactor(value:Number):void { mScaleFactor = value; }
    }
}