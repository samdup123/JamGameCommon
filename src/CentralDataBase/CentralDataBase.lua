local CentralDataBase = {}

CentralDataBase.init = function(resources)
  local systemData = {}

  for i, resource in ipairs(resources) do
    if (systemData[resource.tag]) then
      error('tags repeated')
    else
      systemData[resource.tag] = {data = resource.defaultData, subscriptions = {}}
    end
  end

  return {
    write = function(newData, tag)
      if systemData[tag] then
        systemData[tag].data = newData
        for i, callback in ipairs(systemData[tag].subscriptions) do
          callback(newData)
        end
      end
    end,

    read = function(tag) return systemData[tag].data end,

    subscribe = function(tag, callback)
      table.insert(systemData[tag].subscriptions, callback)
    end,

    unsubscribe = function(tag, callbackToUnsubscribe)
      for i, callback in ipairs(systemData[tag].subscriptions) do
        if callback == callbackToUnsubscribe then table.remove(systemData[tag].subscriptions, i) end
      end
    end
  }
end

return CentralDataBase
