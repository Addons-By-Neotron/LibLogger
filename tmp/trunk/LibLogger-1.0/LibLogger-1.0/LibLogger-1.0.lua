--[[
**********************************************************************
LibLogger is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibLogger is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibLogger.  If not, see <http://www.gnu.org/licenses/>.
**********************************************************************

To use this addon, embed it in your addon using the normal Ace-method
or manually like this:

  LibStub("LibLogger-1.0"):Embed(MyAddon)

After embedding you will be able to use the following methods:

  MyAddon:error( args )
  MyAddon:warn ( args )
  MyAddon:info ( args )
  MyAddon:debug( args ) 
  MyAddon:trace( args )
  MyAddon:spam ( args ) 

  Args is either a string or a format string with subsequent arguments
  being used in the formatting. for example:


  MyAddon:trace("Setting parameter %s to %d.", paramname, value)

  You can set the log level using this method:

  MyAddon:SetLogLevel(level)

  Available levels will be defined in MyAddon.logLevels and are:

    NONE, ERROR, WARN, INFO, DEBUG, TRACE and SPAM

  I.e: MyAddon:SetLogLevel(MyAddons.logLevels.INFO).

  You can return the current log level with:

  level = MyAddon:GetLogLevel()

  There is also an optional performance mode that undefine the logger
  methods you don't need for the current log level:

  MyAddon:SetPerformanceMode(true)

  When you use the performance mode you need to first verify that the
  method is present, i.e:

  if log.trace then log.trace("Trace Message") end

  The reason for using performance mode is that it allows you to do
  calculations in debug messages without having to worry about the
  execution costs (i.e the code is only evaluated when it's actually
  needed).  This is also cleaner than doing a comparision against the
  logging level.

]]

-- This file handles logging of variable levels


local logPrefix = {
   "|cffff0000ERROR:|r ", 
   "|cffffff00WARN:|r ", 
   "", 
   "|cffd9d919DEBUG:|r ", 
   "|cffd9d5fFTRACE:|r ",
   "|cffff5050SPAM:|r ",
}

local MAJOR = "LibLogger-1.0"
local MINOR = string.match("$Revision$", "[0-9]+")

local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

lib.logLevels = { NONE = 0, ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, TRACE = 5, SPAM = 6 }

local logLevels = lib.logLevels

local function LogMessage(level,addon,...)
   if level <= addon.logLevel then
      if  addon.Print then 
	 addon:Print(logPrefix[level]..string.format(...))
      else
	 DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Logger|r: "..logPrefix[level]..string.format(...) )
      end
   end
end

local function debug(...) LogMessage(logLevels.DEBUG, ...) end
local function error(...) LogMessage(logLevels.ERROR, ...) end
local function warn(...) LogMessage(logLevels.WARN,  ...) end
local function info(...) LogMessage(logLevels.INFO,  ...) end
local function trace(...) LogMessage(logLevels.TRACE, ...) end
local function spam(...) LogMessage(logLevels.SPAM, ...) end

function lib:SetLogLevel(level)
   local logLevel = tonumber(level)
   if self.clearUnusedLoggers then 
      if logLevel >= logLevels.ERROR then self.error = error else self.error = nil end
      if logLevel >= logLevels.WARN  then self.warn = warn else self.warn = nil end
      if logLevel >= logLevels.INFO  then self.info = info else self.info = nil end
      if logLevel >= logLevels.DEBUG then self.debug = debug else self.debug = nil end
      if logLevel >= logLevels.TRACE then self.trace = trace else self.trace = nil end
      if logLevel >= logLevels.SPAM  then self.spam = spam else self.spam = nil end
   else
      self.error = error     self.warn = warn 
      self.info = info       self.debug = debug 
      self.trace = trace     self.spam = spam 
   end
   self.logLevel = logLevel
end

function lib:GetLogLevel() return self.logLevel end

function lib:SetPerformanceMode(val)
   self.clearUnusedLoggers = val
end
local embeddables = { "GetLogLevel", "SetLogLevel", "logLevels", "SetPerformanceMode" }

function lib:Embed(addon)
   for _,key in ipairs(embeddables) do
      addon[key] = lib[key]
   end
   if not addon.logLevel then
      addon:SetLogLevel(logLevels.INFO)
   end
end


