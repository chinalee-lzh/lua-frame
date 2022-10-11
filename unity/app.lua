local csapp = import('unity.interface').Application

local isEditor, dataPath, persistentDataPath, streamingAssetsPath, frameRate

return {
  isEditor = function()
    if isnil(isEditor) then isEditor = csapp.isEditor end
    return isEditor
  end,
  dataPath = function()
    if isnil(dataPath) then dataPath = csapp.dataPath end
    return dataPath
  end,
  persistentDataPath = function()
    if isnil(persistentDataPath) then persistentDataPath = csapp.persistentDataPath end
    return persistentDataPath
  end,
  streamingAssetsPath = function()
    if isnil(streamingAssetsPath) then streamingAssetsPath = csapp.streamingAssetsPath end
    return streamingAssetsPath
  end,
  getFPS = function()
    if isnil(frameRate) then
      frameRate = csapp.targetFrameRate
    end
    return frameRate
  end,
  setFPS = function(fps)
    if notnumber(fps) then return end
    frameRate = fps
    csapp.targetFrameRate = fps
  end,
}