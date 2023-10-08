local function onArea(pos_x, pos_y, x,y,w,h)
    return pos_x>=x and pos_x<=(x+w) and pos_y<=(y+h) and pos_y>=y
end

local pressed_data = {
	pressed = false,
	element,
}

local color = {
	red = 0,
	green = 0,
	blue = 0,
}
------------------------------------------------

local path_to_mult = {
	red = {red = 0.65, green = -0.35, blue = -0.35},
	green = {red = -0.35, green = 0.65, blue = -0.35},
	blue = {red = -0.35, green = -0.35, blue = 0.65},
}

local slider_meta = {
	draw = function(self) 
		love.graphics.setColor(0.3, 0.3, 0.3)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
		local val = (self.value/(self.max-self.min))
		love.graphics.setColor(0.35+path_to_mult[self.path].red*val, 0.35+path_to_mult[self.path].green*val, 0.35+path_to_mult[self.path].blue*val)
		love.graphics.rectangle("fill", self.x+1, self.y+1+(self.h-2)*(1-val), self.w-2, (self.h-2)*val)
	end,
	move = function(self, x, y)
		if y<=self.y+1 then
			self.value = self.max 
		elseif y>=self.y+self.h-2 then
			self.value = self.min 
		else
			y = self.h - (y - self.y)
			self.value = y/self.h
		end
		
		color[self.path] = self.value
	end
}

-- vertical
local function createSlider(x,y,w,h,min,max,val,path)
	local ret = {
		x = x,
		y = y,
		w = w,
		h = h,
		min = min,
		max = max,
		value = val,
		path = path,
	}
	return setmetatable(ret, {__index = slider_meta})
end

local sliders = {
	createSlider(210, 10, 25, 180, 0, 1, color.red, "red"),
	createSlider(245, 10, 25, 180, 0, 1, color.green, "green"),
	createSlider(280, 10, 25, 180, 0, 1, color.blue, "blue"),
}

------------------------------------------------

function love.load(...)
	love.graphics.setBackgroundColor(0.6, 0.55, 0.6)
	love.window.setTitle("Colorpicker")
	love.window.setMode(315, 200)
end

function love.mousepressed(x,y,button)
	if pressed_data.pressed then
		return
	end
	for _,v in ipairs(sliders) do
		if onArea(x, y, v.x, v.y, v.w, v.h) then 
			pressed_data.pressed = true
			pressed_data.element = v
			v:move(x,y)
			break
		end
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	pressed_data.pressed = false
end

function love.mousemoved(x, y, dx, dy, istouch)
	if pressed_data.pressed then
		pressed_data.element:move(x,y)
	end
end

function love.keypressed(key)
	if key=="escape" then 
		love.event.quit()
	end
	if key=="space" then
		love.system.setClipboardText("love.graphics.setColor("..string.format("%0.3f, %0.3f, %0.3f)",color.red, color.green, color.blue))
	end
end

function love.draw()
	love.graphics.setColor(color.red, color.green, color.blue)
	love.graphics.rectangle("fill", 10, 5, 190, 190)
	love.graphics.setColor(0.1, 0.1, 0.1)
	love.graphics.rectangle("line", 9, 4, 192, 192)
	
	for _,v in ipairs(sliders) do
		v:draw()
	end
end
