-- Aseprite Script Text Tool 0.6 for Aseprite (https://aseprite.org)
-- Written by Augustin Clement a.k.a Bakadesign (https://github.com/Bakadesignz).
-- The Aseprite APi currently doesn't provide devs a working method to use a text tool by script. That's my atempt at a workaround. 
-- You can "encode" the image of an alphabet/pixel font, then intergrate this data and some of the following functions to draw text bt script.

-- Instructions:
-- Use a transparent png of the alphabet you want to use (see alphabet.png as example)
-- The alphabet should be organized a grid. You can put as many Glyphs as you want, as long as you register them in the abcTable.
-- you can even switch some glyph for another fo convenience, for example in the alphabet.png :
-- I entered the glyph (c) and assigned it to '§' in the abcTable. That way you can use custom glyphs associated to keyboard entry if needed.
-- Finaly enter the dimension of a glyph/grid (8x8 in the example) and hit encode.
-- you now have 2 texts to pass in your script to start using your alphabet
-- you will also need the abcTable, writext() and drawABC(), also the variables marked below ### start ### and ### end ###


-- ### start ###  code to copy to your script for integration

local utf8 = require("utf8")
local sprite = app.activeSprite
local abcImg -- will contain the alphabet picture

-- Size of alphabet's picture, shrinkBounds of this image (triming the empty marging), size of a block containing a glyph/letter.
-- encType is the "encoding" used initialy to transform the alphabet's picture into a string.
-- Note : the string here is cut in separate lines for convenience. Use only .. , don't use \n and \r
local abcInfo = {["encType"]=compact, ["glyph"]={8,8}, ["size"]={256,24}, ["bounds"]={0,0,252,23}}
local abcCode = "01111515101610161111211314114190161999999117151115111715111611511115116119999901101210141510151111141014112141213191815101619996"..
"13121511817151617190141214121517181941712110101141510161015111161510141918161719995141011618151151015111511171611512199316111151"..
"91101115195101710141712193181411111311111921111194151101616118141111714121615121511199219816110199511111610131211310119418161716"..
"11994161216151901618141215161217194171611115192111151951015111131311311019516161016171951151811715111141117151116116171161161718"..
"19418199999999999196119999999999921999999999999999999999999999999991151116111411151111411115111412141116111412141713131215115111"..
"61151116111411111312141313131313131313111151195116196121214121417121417171712151815101517110113110141214121412141214191512141313"..
"13141014131615161915101941010121411151712141115111510114111151815116171010131011412141214121412151171512141313101015161016161718"..
"19941211114121417121417171214121518151161713131214121411151214111816151214131310101517161718171997121412141712141717121412151610"..
"15101517131312141214171214121716151215101410101410161518191619971214111611141115111141811141214111616121411114131312151151811512"..
"14111716117161014131515111151191411941111999999999999999411999999999999999999999999999999999999999999019919411941995161199999999"..
"99999311716119512196199194195171816171999999901999999018171941011017111411151111511151115171114111993121417111141011511511161114"..
"10115115111512141214131311011312141111518171612131012161214121417121412141115121410151816101517101013110141214121412141161816121"..
"41214101015151216151181711410114101216121412141712141116161111410151816116171010131214121412141214171116161215101410101516111517"..
"18171941011017111131115111151114181914101518161011417101013121511511161114191611611161511014110116141111511716119512199994111931"..
"11993199999219019311999990111999999"

-- List of each glyph => {x,y,o}, xy is the column/row position of the glyph in the grid,
-- o is the offset used to trim the right empty space of the glyph (you can usually leave 1 pixel on the right)
abcTable = {
  ["@"]={0,0,0}, ["!"]={1,0,3}, ["\""]={2,0,3}, ["#"]={3,0,1}, ["$"]={4,0,0}, ["%"]={5,0,0}, ["&"]={6,0,0}, ["'"]={7,0,5}, ["("]={8,0,2}, [")"]={9,0,2},
  ["*"]={10,0,1}, ["+"]={11,0,1}, [","]={12,0,3}, ["-"]={13,0,1}, ["."]={14,0,3}, ["/"]={15,0,10}, ["0"]={16,0,2}, ["1"]={17,0,2}, ["2"]={18,0,2}, ["3"]={19,0,2},
  ["4"]={20,0,2}, ["5"]={21,0,2}, ["6"]={22,0,2}, ["7"]={23,0,2}, ["8"]={24,0,2}, ["9"]={25,0,2}, [":"]={26,0,4}, [";"]={27,0,4}, ["<"]={28,0,3}, ["="]={29,0,2},
  [">"]={30,0,3}, ["?"]={31,0,2}, ["A"]={0,1,2}, ["B"]={1,1,2}, ["C"]={2,1,2}, ["D"]={3,1,2}, ["E"]={4,1,2}, ["F"]={5,1,2}, ["G"]={6,1,2}, ["H"]={7,1,2},
  ["I"]={8,1,3}, ["J"]={9,1,2}, ["K"]={10,1,2}, ["L"]={11,1,2}, ["M"]={12,1,1}, ["N"]={13,1,2}, ["O"]={14,1,2}, ["P"]={15,1,2}, ["Q"]={16,1,1}, ["R"]={17,1,2},
  ["S"]={18,1,2}, ["T"]={19,1,2}, ["U"]={20,1,2}, ["V"]={21,1,2}, ["W"]={22,1,1}, ["X"]={23,1,1}, ["Y"]={24,1,2}, ["Z"]={25,1,2}, ["["]={26,1,3}, ["\\"]={27,1,1},
  ["]"]={28,1,3}, ["^"]={29,1,3}, ["_"]={30,1,2}, ["°"]={31,1,3}, ["a"]={0,2,1}, ["b"]={1,2,2}, ["c"]={2,2,2}, ["d"]={3,2,2}, ["e"]={4,2,2}, ["f"]={5,2,3}, ["g"]={6,2,2},
  ["h"]={7,2,3}, ["i"]={8,2,5}, ["j"]={9,2,3}, ["k"]={10,2,2}, ["l"]={11,2,4}, ["m"]={12,2,1}, ["n"]={13,2,2},[ "o"]={14,2,2}, ["p"]={15,2,2}, ["q"]={16,2,2},
  ["r"]={17,2,2}, ["s"]={18,2,3}, ["t"]={19,2,3}, ["u"]={20,2,2}, ["v"]={21,2,2}, ["w"]={22,2,1}, ["x"]={23,2,1}, ["y"]={24,2,2}, ["z"]={25,2,2}, ["{"]={26,2,3},
  ["|"]={27,2,3}, ["}"]={28,2,2}, ["~"]={29,2,1}, ["§"]={30,2,0}, [" "]={31,2,4}
}

-- Redraw the alphabet picture (from the abcCode) and store it at the init of the script (abcImg here). It will be used to write text.
-- encType need to be the same type used to encode the alphabet initialy ("normal", "compact", "alpha")
function drawABC(info, codeImg)
  local sizeImg = info["size"]
  local boundsImg = info["bounds"]
  local encType = info["encType"]
  abcImg = Image(sizeImg[1], sizeImg[2])
  local tempImg = Image(boundsImg[3], boundsImg[4])
  local len = boundsImg[3]
  local tempL = sprite:newLayer()
  local colorImg = Color(0,0,0,255)
  local br = Brush{type=BrushType.SQUARE, size=1}
  tempL.name = "AlphabetLayer"
  local j = 0
  if encType == nil or encType == "normal" or encType == "compact" then
    local k = 0
    for i = 1, string.len(codeImg), 1 do
      local nb = tonumber(string.sub(codeImg, i, i))
      if nb == 1 then
        app.useTool{tool = "pencil", color = colorImg, brush = br, points = {Point(k%len, j)}, layer = tempL, frame = 1}
        k = k+1
      elseif nb == 0 then k=k+1 else k=k+nb end
      if k >= len then k=k%len j=j+1 end
    end
  elseif encType == "alpha" then
    local col = colorImg
    for i = 1, string.len(codeImg), 1 do
      local nb = tonumber(string.sub(codeImg, i, i))
      if nb == 1 then
        app.useTool{tool = "pencil", color = colorImg, brush = br, points = {Point((i-1)%len, j)}, layer = tempL, frame = 1}
      elseif nb > 1 then
        col.alpha = 32*(nb-1)
        app.useTool{tool = "pencil", color = col, brush = br, points = {Point((i-1)%len, j)}, layer = tempL, frame = 1}
        col.alpha = 255
      end
      if i%len == 0 then j = j+1 end
    end
  end
  local tempCel = tempL:cel(1)
  tempImg:drawImage(tempCel.image)
  abcImg:drawImage(tempImg, {boundsImg[1], boundsImg[2]}, 255)
  sprite:deleteLayer(tempL)
  --app.image:drawImage(abcImg, {0, 0}, 255) -- test to draw the entire alphabet at the start of the script
end

-- [tx] text to display, [origin] display position (Point)
-- following parameters are optionals :
-- [adjust] letter spacing (in addtion of each individual glyph offset).
-- [center] if not 0/nil, then the text will be centered betwwen origin.x and origin.x + center value.
-- [color] color of the text, Foreground color if nil
-- [bgc] color for a background rectangle, [mg] margin within that Background rectangle.
-- [bdc] border color, [thick] thickness of the border, it's an internal border, so you'll have to play with the margin value aswell.
function writeText(txt, origin, adjust, center, color, bgc, mg, bdc, thick)
  local targetImg = app.image
  if targetImg == nil then app.alert("no image/cel selected") return end
  local blk = abcInfo["glyph"]
  local adj = (adjust == nil and 0 or adjust)
  local ct = (center == nil and 0 or center)
  local col = (color == nil and app.fgColor or color)
  local length = utf8.len(txt)
  local cps = { utf8.codepoint(txt, 1, -1) }
  local tempImg = Image(length*(blk[1]+adj), blk[2])
  local tempChar = Image(blk[1],blk[2])
  local charPos = {0, 0}
  local offset = 0
  local mgx = 0
  local mgy = 0
  local cut = 0
  for c = 1, utf8.len(txt), 1 do
    charPos = abcTable[utf8.char(cps[c])]
    for j = 0, (blk[2]-1), 1 do
      for i = 0, (blk[1]-1-charPos[3]), 1 do
        local pix = abcImg:getPixel((charPos[1]*blk[1])+i,(charPos[2]*blk[2])+j)
        col.alpha = app.pixelColor.rgbaA(pix)
        if col.alpha > 0 then tempChar:drawPixel(i, j, col) end
      end
    end
    cut = cut + charPos[3]
    tempImg:drawImage(tempChar, (c-1)*blk[1]-offset, 0)
    tempChar:clear()
    offset = offset + charPos[3] - adj
  end
  local rect = tempImg:shrinkBounds()
  local br = Brush{type=BrushType.SQUARE, size=1}
  if ct > 0 then mgx = math.floor((ct-rect.width)/2) end
  if mg ~= nil and bgc ~= nil then
    mgx = mgx+mg 
    mgy = mg
    app.useTool{tool="filled_rectangle", color=bgc, brush=br, points={Point(origin.x, origin.y), Point(origin.x+rect.width-1+mg*2, origin.y+rect.height-1+mg*2)}}
    if thick ~= nil and bdc ~= nil then
      br = Brush{type=BrushType.SQUARE, size=thick}
      app.useTool{tool="rectangle", color=bdc, brush=br, points={Point(origin.x, origin.y), Point(origin.x+rect.width-1+mg*2, origin.y+rect.height-1+mg*2)}}
    end
    targetImg:drawImage(tempImg, mgx, mgy)
  else
    targetImg:drawImage(tempImg, origin.x + mgx, origin.y + mgy)
  end
end
-- you need to launch the function drawABC(abcInfo, abcCode), see the init part at the end of the script

-- ### end ### 


-- Scan and encode the current cel/image to create a new set of datas for a new alphabet
-- The alphabet.png was encoded and used in this script, you can create your own and encode it
function encodeABC(encType, wg, hg, fields)
  local Img
  if app.image == nil then
    app.alert("No image/cell selected")
    return
  else
    Img = app.image
  end
  local pc = app.pixelColor
  local cell = app.cel
  local bds = cell.image:shrinkBounds()
  local abcStr = "local abcInfo = {[\"encType\"]="..encType..", ".."[\"glyph\"]={"..wg..","..hg.."}, "
  local imgStr = ""
  if encType == "compact" then
    local nb = 0
    for it in Img:pixels() do
      if pc.rgbaA(it()) == 0 then
        nb = nb + 1
        if nb == 9 then imgStr=imgStr.."9" nb=0 end
      else
        if nb == 1 then imgStr=imgStr.."0" end
        if nb > 1 then imgStr=imgStr..nb end
        nb = 0
        imgStr = imgStr .. "1"
      end
    end
  elseif encType == "alpha" then
    local nb = 0
    for it in Img:pixels() do
      local al = pc.rgbaA(it())
      if al == 0 then imgStr = imgStr .. "0"
      elseif al == 255 then imgStr = imgStr .. "1"
      else
        nb = math.max(math.floor(al/32+1.5))
        imgStr = imgStr..nb
      end
    end
  elseif encType == "normal" then
    for it in Img:pixels() do
      if pc.rgbaA(it()) == 0 then imgStr = imgStr .. "0" else imgStr = imgStr .. "1" end
    end
  end
  fields[1]:modify{id="enc_txt", text="hello"}
  abcStr = abcStr.."[\"size\"]={"..sprite.width..","..sprite.height.."}, ".."[\"bounds\"]={"..bds.x..","..bds.y..","..bds.w..","..bds.h.."}}"
  fields[1]:modify{id = fields[2], text = "local abcCode = \""..imgStr.."\""}
  fields[1]:modify{id = fields[3], text = abcStr}
end

-- the dialog
local dlg
local DEFAULT_GROUP_TEXT = "Enter text"

function showDialog()
  dlg = Dialog {title="Alphabet Utils", resizeable=false, hexpand=false, vexpand=false}
  :separator{text = "Text Testing"}
  :newrow()
  :entry{id="test_text", label="Text :", text=DEFAULT_GROUP_TEXT, focus=false}
  :entry{id="posx", label="Position", text="1", focus=false}
  :entry{id="posy", text="1", focus=false }
  :color{id="txtcol", label="Font color",color=app.fgColor}
  :slider{id="char_spacing", label="Char space", min=-2, max=2, value=0}
  :check{id="isbg", text="Background", selected=false,
      onclick=function() 
        local UId = dlg.data
        if UId.isbg then
          dlg:modify{id="bgcol", visible=true} dlg:modify{id="bgmg", visible=true}
          dlg:modify{id="bdcol", visible=true} dlg:modify{id="bdth", visible=true}
          dlg:modify{id="isbd", visible=true}
          app.refresh()
        else
          dlg:modify{id="bgcol", visible=false} dlg:modify{id="bgmg", visible=false}
          dlg:modify{id="bdcol", visible=false} dlg:modify{id="bdth", visible=false}
          dlg:modify{id="isbd", visible=false} dlg:modify{id="isbd", selected=false}
          app.refresh()
        end
      end
  }
  :color{id="bgcol", label="BG color", color=app.bgColor, visible=false}
  :slider{id="bgmg", label="BG margin", min=0, max=10, value=0, visible=false}
  :check{id="isbd", text="Border", selected=false, visible=false}
  :color{id="bdcol", label="Border color", color=app.fgColor, visible=false}
  :slider{id="bdth", label="Thickness", min=0, max=10, value=0, visible=false}
  :separator{}
  :button {text="Generate Text", focus=true,
      onclick=function()
          local UId = dlg.data
          local bgc=nil local bgmg=nil local bdc=nil local bdth=nil
          if UId.isbg then
            bgc=UId.bgcol bgmg=UId.bgmg
            if UId.isbd then bdc=UId.bdcol bdth=UId.bdth end
          end
          app.transaction("write_text", function() writeText(UId.test_text, Point( UId.posx, UId.posy), UId.char_spacing, 0, UId.txtcol, bgc, bgmg, bdc, bdth) end)
          app.refresh()
      end
  }
  :separator{text = "EncodIng Alphabet"}
  :combobox{id ="etype", label="type", option="compact", options={"compact","alpha","normal"}}
  :entry{id="wglyph", label="Glyph size", text="8", focus=false}
  :entry{id="hglyph", text="8", focus=false}
  :button{text="Encode", focus=true,
      onclick=function()
        local UId = dlg.data
          encodeABC(UId.etype, UId.wglyph, UId.hglyph, {dlg, "enc_txt", "enc_info"})
          app.refresh()
      end
  }
  :label{text="Datas to use in your script"}
  :entry{id="enc_txt", label="Copy encoding :", text=""}
  :entry{id="enc_info", label="Copy infos :", text=""}
  dlg:show{wait=false, bounds=Rectangle(dlg.bounds["x"], dlg.bounds["y"], 200, 285)}
end

-- Init the alphabet then the dialog
do
  drawABC(abcInfo, abcCode)
  showDialog()
end
