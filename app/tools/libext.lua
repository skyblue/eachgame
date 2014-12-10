-- jit模式下为毫秒值
-- if jit and jit.status and jit.status() then
--   local clock__ = os.clock
--   os.clock = function()
--     return clock__()/10000
--   end
-- end

-- Compute the difference in seconds and hour between local time and UTC.
function os.timezone()
  -- local now = os.time()
  -- local sec = os.difftime(now, os.time(os.date("!*t", now)))
  -- return sec, sec/3600
  local ts = os.time()
  local utcdate   = os.date("!*t", ts)
  local localdate = os.date("*t", ts)
  localdate.isdst = false -- this is the trick
  local sec = os.difftime(os.time(localdate), os.time(utcdate))
  return sec, sec/3600
end

number = {}
local numberToMonth = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
function number.toMonth(n)
  n = tonumber(n)
  return numberToMonth[n]
end

function number.tocurrency(n)
  return "$" .. number.commaSeperate(n)
end


function string.urlencode(s)
    s = string.gsub(tostring(s), "\n", "\r\n")
    s = string.gsub(s, "([^A-Za-z0-9_%.-_.!~*'()])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
    return s
end


function string.urldecode(s)
    return string.gsub(s, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end
--取模和余
function math.mod(x,y)
  return math.floor(x/y),math.fmod(x,y)
end
-- function number.commaSeperate(n)
--   local formatted = tostring(n)
--   while true do
--     formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
--     if k ==0 then break end
--   end

--   return formatted
-- end

-- function string.ucfirst(str)
    -- return str:sub(1,1):upper()..str:sub(2)
    -- return (str:gsub("^%l", string.upper))
-- end


-- function string.split(s,re)
--   local i1 = 1
--   local ls = {}
--   local append = table.insert
--   if not re then re = '%s+' end
--   if re == '' then return {s} end
--   while true do
--     local i2,i3 = s:find(re,i1)
--     if not i2 then
--       local last = s:sub(i1)
--       if last ~= '' then append(ls,last) end
--       if #ls == 1 and ls[1] == '' then
--         return {}
--       else
--         return ls
--       end
--   end
--   append(ls,s:sub(i1,i2-1))
--   i1 = i3+1
--   end
-- end

-- for name, line in pairsByKeys(lines) do
--     print(name, line)
-- end
function table.pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0                 -- iterator variable
    local iter = function ()    -- iterator function
       i = i + 1
       if a[i] == nil then return nil
       else return a[i], t[a[i]]
       end
    end
    return iter
end

function table.clone(t, meta)
  local u = {}

  if meta then
    setmetatable(u, getmetatable(t))
  end

  for i, v in pairs(t) do
    if type(v) == "table" then
      u[i] = table.clone(v)
    else
      u[i] = v
    end
  end

  return u
end


function table.keys(t)
  local keys = {}
  for k, v in pairs(t) do table.insert(keys, k) end
  return keys
end

function table.unique(t)
  local seen = {}
  for i, v in ipairs(t) do
    if not table.indexOf(seen, v) then table.insert(seen, v) end
  end

  return seen
end

function table.values(t)
  local values = {}
  for k, v in pairs(t) do table.insert(values, v) end
  return values
end

function table.last(t)
  return t[#t]
end

function table.append(t, moreValues)
  for i, v in ipairs(moreValues) do
    table.insert(t, v)
  end

  return t
end

function table.indexOf(t, value)
  for k, v in pairs(t) do
    if type(value) == "function" then
      if value(v) then return k end
    else
      if v == value then return k end
    end
  end

  return nil
end

function table.includes(t, value)
  return table.indexOf(t, value)
end

function table.removeValue(t, value)
  local index = table.indexOf(t, value)
  if index then table.remove(t, index) end
  return t
end

function table.empty(t)
  for k,v in pairs(t) do t[k]=nil end
  return t
end

function table.removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function table.each(t, func)
  for k, v in pairs(t) do
    func(v, k)
  end
end

function table.find(t, func)
  for k, v in pairs(t) do
    if func(v) then return v, k end
  end

  return nil
end

function table.filter(t, func)
  local matches = {}
  for k, v in pairs(t) do
    if func(v) then table.insert(matches, v) end
  end

  return matches
end

function table.map(t, func)
  local mapped = {}
  for k, v in pairs(t) do
    table.insert(mapped, func(v, k))
  end

  return mapped
end

function table.groupBy(t, func)
  local grouped = {}
  for k, v in pairs(t) do
    local groupKey = func(v)
    if not grouped[groupKey] then grouped[groupKey] = {} end
    table.insert(grouped[groupKey], v)
  end

  return grouped
end

function table.tostring(tbl, indent, limit, depth, jstack)
  limit   = limit  or 1000
  depth   = depth  or 7
  jstack  = jstack or {}
  local i = 0

  local output = {}
  if type(tbl) == "table" then
    -- very important to avoid disgracing ourselves with circular referencs...
    for i,t in ipairs(jstack) do
      if tbl == t then
        return "<self>,\n"
      end
    end
    table.insert(jstack, tbl)

    table.insert(output, "{\n")
    for key, value in pairs(tbl) do
      local innerIndent = (indent or " ") .. (indent or " ")
      table.insert(output, innerIndent .. tostring(key) .. " = ")
      table.insert(output,
        value == tbl and "<self>," or table.tostring(value, innerIndent, limit, depth, jstack)
      )

      i = i + 1
      if i > limit then
        table.insert(output, (innerIndent or "") .. "...\n")
        break
      end
    end

    table.insert(output, indent and (indent or "") .. "},\n" or "}")
  else
    if type(tbl) == "string" then tbl = string.format("%q", tbl) end -- quote strings
    table.insert(output, tostring(tbl) .. ",\n")
  end

  return table.concat(output)
end

function table.defaults(t,defaults)
  for k, v in pairs(defaults) do
    if t[k] == nil then t[k] = v end
  end
  return t
end

function table.slice (t,i1,i2)
  local res = {}
  local n = #t
  -- default t for range
  i1 = i1 or 1
  i2 = i2 or n
  if i2 < 0 then
    i2 = n + i2 + 1
  elseif i2 > n then
    i2 = n
  end
  if i1 < 1 or i1 > n then
    return res
  end
  local k = 1
  for i = i1,i2 do
    res[k] = t[i]
    k = k + 1
  end
  return res
end

function table.splice(t,i1,i2)
end