local CSApp = CS.UnityEngine.Application

return {
  isEditor = function() return CSApp.isEditor end,
  dataPath = function() return CSApp.dataPath end,
  persistentDataPath = function() return CSApp.persistentDataPath end,
  streamingAssetsPath = function() return CSApp.streamingAssetsPath end,
  getFPS = function() return CSApp.targetFrameRate end,
  setFPS = function(fps) if isnumber(fps) then CSApp.targetFrameRate = fps end end,
}