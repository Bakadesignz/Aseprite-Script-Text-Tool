local mytext = {{57,7},"1218131941319516112181319413195161111131112131411710101311310112141111212121213131216101012121211413121121211131313121610101212121513121121215131411810141131514111711199999"}

function drawWord(wtab, color)
local img = Image(wtab[1][1], wtab[1][2])
local j = 0
local k = 0
local len = wtab[1][1]
for i = 1, string.len(wtab[2]), 1 do
local nb = tonumber(string.sub(wtab[2], i, i))
if nb == 1 then
img:drawPixel(k%len, j, color)
k = k+1
elseif nb == 0 then k=k+1 else k=k+nb end
if k >= len then k=k%len j=j+1 end
end
return img
end

local image = app.image
app.useTool{tool = "filled_rectangle", color = Color(255,255,255,255), points = {Point(0,0), Point(80, 20)}}
image:drawImage(drawWord(mytext, Color(0,0,0,255)), Point(11, 8))