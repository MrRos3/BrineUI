-- Real Tab module with a small engine boundary. Not a rendering test.
local function signal()
	local callbacks = {}
	return { Connect = function(_, callback)
		local connection = { Connected = true }
		function connection:Disconnect() self.Connected = false end
		table.insert(callbacks, { callback, connection })
		return connection
	end, Fire = function(_, ...)
		for _, entry in callbacks do if entry[2].Connected then entry[1](...) end end
	end }
end
local Vector2 = {new = function(x,y) return {X=x,Y=y} end}
local UDim = {new = function(s,o) return {Scale=s,Offset=o} end}
local UDim2 = {new = function(xs,xo,ys,yo) return {X=UDim.new(xs,xo),Y=UDim.new(ys,yo)} end}
UDim2.fromOffset = function(x,y) return UDim2.new(0,x,0,y) end
local Enum = {FontWeight={Medium=1,SemiBold=2,Regular=3},EasingStyle={Quart=1,Quint=2},EasingDirection={Out=1}}
local Font = {new=function() return {} end}
local function new(class,props,children)
	local obj = {Name=class,AbsoluteSize=Vector2.new(160,20),AbsolutePosition=Vector2.new(0,0),TextBounds=Vector2.new(60,18)}
	for _,event in ipairs({'MouseButton1Click','InputBegan','InputEnded','MouseEnter','ChildAdded'}) do obj[event]=signal() end
	obj._signals={}
	function obj:GetPropertyChangedSignal(key)
		self._signals[key]=self._signals[key] or signal()
		return self._signals[key]
	end
	for key,value in props or {} do obj[key]=value end
	for _,child in children or {} do obj[child.Name]=child;child.Parent=obj end
	return obj
end
local Creator={New=new,Font='native'}
Creator.NewRoundFrame=function(_,_,props,children) return new('ImageButton',props,children) end
Creator.AddSignal=function(event,callback) return event:Connect(callback) end
Creator.Tween=function(obj,_,props) return {Play=function() for k,v in props do obj[k]=v end end} end
Creator.SetThemeTag=function(obj,props) obj.ThemeTag=props end
Creator.Image=function() return new('Frame',{}, {new('ImageLabel',{})}) end
local queue={}
local task={spawn=function(fn) table.insert(queue,fn);return fn end,wait=function() end,cancel=function() end}
local function flush() local batch=queue;queue={};for _,fn in batch do fn() end end
local mouse={Move=signal(),X=0,Y=0}
local game={GetService=function(_,name)
	if name=='Players' then return {LocalPlayer={GetMouse=function() return mouse end}} end
	if name=='TweenService' then return {Create=function(_,obj,_,props) return Creator.Tween(obj,0,props) end} end
	return {}
end}
local TweenInfo={new=function() return {} end}
local tooltipCount=0
local require=function(name)
	if name=='../../modules/Creator' then return Creator end
	if name=='../ui/Tooltip' then return {New=function(desc)
		tooltipCount+=1
		return {Container={},Open=function() end,Close=function() end,Desc=desc}
	end} end
	if name=='../../modules/ScreenSpace' then return {Mouse=function() return setmetatable({X=0,Y=0},{__sub=function(a) return a end}) end,Origin=function() return {X=0,Y=0} end} end
	if name=='../../modules/Glass' then return {Pane=function(_,props) return new('Frame',props) end} end
	if name=='../ui/ScrollSlider' then return {New=function() end} end
	if name=='../../elements/Init' then return {Elements={},Load=function() end} end
	error('Unexpected require '..name)
end
-- INSERT TAB MODULE
local Window={UICorner=16,UIPadding=14,UIElements={MainBar=new('Frame',{}),Main={Main={Topbar={AbsoluteSize=Vector2.new(0,52)}}}},AllElements={}}
TabModule.Init(Window,{}, {})
local changes={}
TabModule:OnChange(function(index)table.insert(changes,index)end)
local parent=new('Frame',{})
local first=TabModule.New({Title='Session',Parent=parent},1)
local second=TabModule.New({Title='Controls',Icon='sliders',Parent=parent},1)
local locked=TabModule.New({Title='Private',Locked=true,Parent=parent},1)
flush()
assert(TabModule.TabCount==3)
first:Select();flush()
assert(first.Selected and first.ContainerFrame.Visible)
-- Only the selected tab has a filled, lit pill.
local function plate(tab)
	assert(tab.UIElements.Glass.Visible==(tab.UIElements.Main.ThemeTag.ImageTransparency=='TabBackgroundActiveTransparency'))
	return tab.UIElements.Main.ThemeTag.ImageTransparency
end
local function ink(tab) return tab.UIElements.Main.Frame.TextLabel.ThemeTag.TextTransparency end
assert(plate(first)=='TabBackgroundActiveTransparency')
assert(plate(second)=='TabBorderTransparency')
second.UIElements.Main.MouseButton1Click:Fire();flush()
assert(second.Selected and not first.Selected)
assert(second.ContainerFrame.Visible and not first.ContainerFrame.Visible)
assert(plate(first)=='TabBorderTransparency' and plate(second)=='TabBackgroundActiveTransparency')
assert(ink(second)=='TabTextTransparencyActive')
locked.UIElements.Main.MouseButton1Click:Fire();flush()
assert(TabModule.SelectedTab==2 and #changes==2,'Locked tab emitted selection')
second:SetTitle('A longer control title')
assert(second.Title==second.UIElements.Main.Frame.TextLabel.Text)
assert(second.ContainerFrame.TabTitle.TextLabel.Text==second.Title)
second:SetDesc('Added after creation')
second.UIElements.Main.InputBegan:Fire();flush()
assert(tooltipCount==1,'Dynamic description did not create tooltip')
second.UIElements.Main.InputEnded:Fire()
second:Lock();first:Select();flush();second:Select();flush()
assert(TabModule.SelectedTab==1)
second:Unlock();second:Select();flush()
assert(TabModule.SelectedTab==2)
locked:Unlock();locked:Select();flush()
assert(TabModule.SelectedTab==3)
local callbackCount=#changes
locked:Lock();locked:Unlock();flush()
assert(#changes==callbackCount,'Unlock should not emit a selection callback')
assert(plate(locked)=='TabBackgroundActiveTransparency')
assert(not second.Selected and not first.Selected,'More than one tab is selected')
-- A tab locked while selected must not stay selected once another tab opens.
second:Select();flush();second:Lock();first:Select();flush()
assert(first.Selected and not second.Selected and plate(second)=='TabBorderTransparency')
print('PASS: real navigation module: click/programmatic selection, locked tab, content visibility, callbacks, title, dynamic tooltip, unlock, glass pill.')
