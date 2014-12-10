local Analytics = {}

local SDK_CLASS_NAME = "MobClickBridge"


function Analytics.init()
    local policy = DEBUG > 0 and 6 or 1
    local args = {appKey = CONFIG.umengid, reportPolicy = policy, channelId = CONFIG.channel, debug = 0}
    utils.callStaticMethod(SDK_CLASS_NAME, "init", args, {"appKey", "debug"}, "(SZ)V")
end

-- function Analytics._send(method, ... )
--     if DEBUG > 0 then return end
--     if Analytics.MobClick then
--         Analytics.MobClick[method](...)
--     end
-- end

-- function Analytics.event(...)
--     Analytics._send("event", ...)
-- end


-- function Analytics.beginEvent(...)
--     Analytics._send("beginEvent", ...)
-- end

-- function Analytics.endEvent(...)
--     Analytics._send("endEvent", ...)
-- end

function Analytics.beginLogPageView(...) do return end
    Analytics._send("beginLogPageView", ...)
end

function Analytics.endLogPageView(...) do return end
    Analytics._send("endLogPageView", ...)
end

--[[--

发送事件
@eventId         string
@label   int
@channelId      string
TODO 暂时只支持label  未支持更多参数的
]]
function Analytics.event(eventId, attrs) do return end
    if type(eventId) ~= "string" then return end
    -- assert(type(eventId) == "string" , "[MobClick.event]  invalid params")
    local args = {
        eventId = eventId,
    }
    if type(attrs) == "string" then
        args.label = attrs
    elseif type(attrs) == "table" and attrs.label then
        args.label = attrs.label
    end

    if args.label then
        utils.callStaticMethod(SDK_CLASS_NAME, "event", args, {"eventId", "label"}, "(SS)V")
    else
        utils.callStaticMethod(SDK_CLASS_NAME, "event", args, {"eventId"})
    end
    print("MobClick Event:",eventId)
end


function Analytics.beginEvent(eventId, label, attrs) do return end
    if type(eventId) ~= "string" then return end
    local args = {
        eventId = eventId,
        label = label
    }
    if  type(attrs) == "table"  then
        table.merge(args,attr)
    end

    local args_order  = {"eventId"}
    if args.label then
        table.insert(args_order,"label")
    end
    utils.callStaticMethod(SDK_CLASS_NAME, "beginEvent", args, args_order)
    print("MobClick beginEvent:",eventId, label)
end

function Analytics.endEvent(eventId,label) do return end
    if type(eventId) ~= "string" then return end
    local args = {
        eventId = eventId,
        label = label
    }

    local args_order  = {"eventId"}
    if args.label then
        table.insert(args_order,"label")
    end
    utils.callStaticMethod(SDK_CLASS_NAME, "endEvent", args, args_order)
    print("MobClick endEvent:",eventId, label)
end


Analytics.init()
return Analytics
